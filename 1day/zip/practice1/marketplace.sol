pragma solidity 0.8.26;

contract MarketPlace{
    struct Item {
        uint256 id;
        address payable seller;
        string name;
        uint256 price;
        bool sold;
    }
    uint256 public itemCount;
    mapping (uint256 => Item) items;
    event ItemListed(uint id, address seller, string name, uint price);
    event ItemSold(uint id, address buyer, uint price);

    function listItem(string memory name, uint256 price) external {
        itemCount++;
        items[itemCount] = Item(itemCount, payable(msg.sender), name, price, false);
        emit ItemListed(itemCount, msg.sender, name, price);
    }

    
    function buyItem(uint256 id) external payable{
        Item storage item = items[id];
        require(id > 0 && id <= itemCount, "invalid item ID");
        require(!item.sold, "item sold");
        require(msg.value == item.price, "incorrect price");

        (bool success, ) = item.seller.call{value: item.price}("");
        require(success, "transfer failed");

        item.sold = true;
        emit ItemSold(id, msg.sender, msg.value);
    }

    function getItem(uint256 id) external view returns(Item memory){
        return  items[id];
    }
}