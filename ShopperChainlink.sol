// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Shopper {
    IERC20 public caliToken;
    AggregatorV3Interface internal priceFeed;
    address public owner;
    uint256 public usdPerToken; // Precio del token en dólares, con 2 decimales (ejemplo: $10.00 = 1000)

//El constructor es muy importante por que define muchas variables dentro del contrato//
constructor(address _caliTokenAddress, address _priceFeedAddress, uint256 _usdPerToken) {
    caliToken = IERC20(_caliTokenAddress); //Asignar direccion de token
    priceFeed = AggregatorV3Interface(_0x694AA1769357215DE4FAC081bf1f309aDC325306); // Asignar _priceFeedAddress a priceFeed
    owner = msg.sender;
    usdPerToken = _usdPerToken;
}


    // Función para obtener el último precio de ETH/USD desde Chainlink
    function getLatestETHPrice() public view returns (uint256) {
        (,int price,,,) = priceFeed.latestRoundData();
        return uint256(price);
    }

    // Función para comprar tokens
    function buyTokens() public payable {
        uint256 ethPrice = getLatestETHPrice(); // Precio de ETH en USD con 8 decimales
        uint256 ethAmountInUsd = (msg.value * ethPrice) / 1e8; // Convertir ETH enviado a USD
        uint256 tokensToBuy = ethAmountInUsd / usdPerToken; // Calcular la cantidad de tokens a comprar
        require(tokensToBuy > 0, "Debes enviar suficiente ETH para comprar al menos un token");
        uint256 contractBalance = caliToken.balanceOf(address(this));
        require(contractBalance >= tokensToBuy, "El contrato no tiene suficientes tokens");
        caliToken.transfer(msg.sender, tokensToBuy);
    }

    // Función para retirar ETH del contrato
    function withdrawETH() public {
        require(msg.sender == owner, "Solo el propietario puede retirar ETH");
        payable(owner).transfer(address(this).balance);
    }

    // Función para establecer el precio del token en USD
    function setUsdPerToken(uint256 _newPrice) public {
        require(msg.sender == owner, "Solo el propietario puede cambiar el precio");
        usdPerToken = _newPrice;
    }
}

