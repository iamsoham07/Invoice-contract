// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;


contract InvoiceToken{
    struct Invoice {
        address sellerPan;
        address buyerPan;
        uint amount;
        string message;
        bool paid;
    }
    uint256 date;

    Invoice[] internal invoices;
    
    mapping (address => uint[]) internal sellers;
    mapping (address => uint[]) internal buyers;
    mapping (address => uint) public balances;
    
    function addInvoice(address fromAddress, uint amount, string memory message) public {
        Invoice memory inv = Invoice({
            buyerPan: fromAddress,
            sellerPan: msg.sender, 
            amount: amount,
            message: message,
            paid: false

        });
        

        invoices.push(inv);
        sellers[inv.sellerPan].push(invoices.length - 1);
        buyers[inv.buyerPan].push(invoices.length - 1);
    }
    
    function viewInvoice(uint id) public view returns(address, address, uint, string memory, bool) {
        Invoice memory inv = invoices[id];
        return (inv.sellerPan, inv.buyerPan, inv.amount, inv.message, inv.paid);
    }
    
    
    function getIncomingInvoices(address buyerAddress, uint idx) public view returns (uint, address, uint, string memory, bool) {
        Invoice memory inv = invoices[ buyers[buyerAddress][idx] ];
        return (buyers[buyerAddress][idx], inv.buyerPan, inv.amount, inv.message, inv.paid);
    }
    function numberOfIncomingInvoices(address buyerAddress) public view returns (uint) {
        return buyers[buyerAddress].length;
    }

    function getOutgoingInvoice(address sellerAddress, uint idx) public view returns (uint, address, uint, string memory, bool) {
        Invoice memory inv = invoices[ sellers[sellerAddress][idx] ];
        return (sellers[sellerAddress][idx], inv.sellerPan, inv.amount, inv.message, inv.paid);
    }
    function numberOfOutgoingInvoices(address sellerAddress) public view returns (uint) {
        return sellers[sellerAddress].length;
    }
    
    function pay(uint id) public payable {
        Invoice storage inv = invoices[id];
        
        require(inv.paid == false);
        require(inv.buyerPan == msg.sender);
        require( msg.value == inv.amount);
        
        inv.paid = true;
        balances[inv.sellerPan] += msg.value;
    }
    
    function withdraw() public {
        require(balances[msg.sender] != 0);
        
        uint toWithdraw = balances[msg.sender];
        balances[msg.sender] = 0;
        payable(msg.sender).transfer(toWithdraw);
    }
    function setInvoiceDate(uint256 _date) public {
        date= _date;
    }
    function getInvoiceDate() public view returns(uint256 _date){
        return date;
    }
}
