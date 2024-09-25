// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "./IERC721.sol";
import "./IERC721Receiver.sol";
import "./wnft.sol";

contract nft_market is IERC721Receiver {
    error NotApproval();
    error PriceLess0();
    error NotOwner();
    error NftNotInContract();
    error MoneyNotEnough();
    error WalletAmountNotEnough();
    
    event List(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Purchase(address indexed buyer, address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event Revoke(address indexed seller, address indexed nftAddr, uint256 indexed tokenId);    
    event Update(address indexed seller, address indexed nftAddr, uint256 indexed tokenId, uint256 newPrice);

    // NFT order 映射
    mapping(address => mapping (uint256 => Order)) public nftList;

    //order 
    struct Order{
        address owner;
        uint256 price;
    }

    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4){
        return IERC721Receiver.onERC721Received.selector;
    }

    fallback() external payable {}
    
    //    // 挂单: 卖家上架NFT，合约地址为_nftAddr，tokenId为_tokenId，价格_price为以太坊（单位是wei）
    function list(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddr);
        if(_nft.getApproved(_tokenId) != address(this)){
            revert NotApproval();
        }
        if(_price <= 0){
            revert PriceLess0();
        }

        Order storage _order = nftList[_nftAddr][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;
        
        //将这个nft转账到合约
        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        //发送挂单事件
        emit List(msg.sender, _nftAddr, _tokenId, _price);
    }

    //撤单事件
    function list(address _nftAddr, uint256 _tokenId) public {
        //先从记录中取出订单
        Order storage _order = nftList[_nftAddr][_tokenId];
        if(_order.owner != msg.sender){
            revert NotOwner();
        }
        //校验NFT
        IERC721 _nft = IERC721(_nftAddr);
        if(_nft.ownerOf(_tokenId) != address(this)){
            revert NftNotInContract();
        }

        //nft 转回给卖家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);

        //从数据库中删除记录
        delete nftList[_nftAddr][_tokenId];

        //发送Revoke事件
        emit Revoke(msg.sender, _nftAddr, _tokenId);
    }

    //修改价格
    function update(address _nftAddr, uint256 _tokenId, uint256 _price) public {
        Order storage _order = nftList[_nftAddr][_tokenId];
        if(_order.owner != msg.sender){
            revert NotOwner();
        }
        //校验NFT
        IERC721 _nft = IERC721(_nftAddr);
        if(_nft.ownerOf(_tokenId) != address(this)){
            revert NftNotInContract();
        }
        //价格校验
        if(_price <= 0){
            revert PriceLess0();
        }

        _order.price = _price;

        emit Update(msg.sender, _nftAddr, _tokenId, _price);
    }

    //购买nft
    function purchase(address _nftAddr, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddr][_tokenId];
        //校验出价价格是否 >= 挂单价格
        if(msg.value < _order.price){
            revert MoneyNotEnough();
        }

        //nft 是否在合约内
                //校验NFT
        IERC721 _nft = IERC721(_nftAddr);
        if(_nft.ownerOf(_tokenId) != address(this)){
            revert NftNotInContract();
        }
        //nft 转账给 买家
        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        //钱转给卖家
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        //从数据库中删除记录
         delete nftList[_nftAddr][_tokenId]; // 删除order
        //发送事件
        emit Purchase(msg.sender, _nftAddr, _tokenId, _order.price);
    }
}