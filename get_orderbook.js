const ccxt = require('./apis/ccxt-master/ccxt.js');


const doMain = async (apis) => {


    let orderbook = [];

    for (let i = 0; i < apis.length; i++) {
        let api = apis[i];

        if (api.exchange.toUpperCase() === "KUCOIN") {
            orderbook = orderbook.concat(await getOrderBook_Kucoin(api));

        };


        if (api.exchange.toUpperCase() === "BITTREX") {
            orderbook = orderbook.concat(await getOrderBook_Latoken(api));

        };

        if (api.exchange.toUpperCase() === "LATOKEN") {
            orderbook = orderbook.concat(await getOrderBook_Latoken(api));

        };



    }

    return orderbook;


}


const getOrderBook_Kucoin = async (api) => {


    const exchange = new ccxt.kucoin({
        "apiKey": api.api_key,
        "secret": api.api_secret,
        "password": api.api_passphrase,
    })


    const orderbook = [];


    const symbol = 'DFI/BTC';
    const response = await exchange.fetchOrderBook(symbol);

    let datetime = response.datetime;
    console.log(response);
    let sequence = response.nonce;
    let side = 'sell';

    for (let i = 0; i < response.asks.length; i++) {
        let price = response.asks[i][0];
        let amount = response.asks[i][1];

        orderbook.push([sequence, symbol, side, price, amount, datetime]);
    }

    side = 'buy';
    for (let i = 0; i < response.bids.length; i++) {
        let price = response.bids[i][0];
        let amount = response.bids[i][1];

        orderbook.push([sequence, symbol, side, price, amount, datetime]);
    }

    return orderbook;


};


const getOrderBook_Latoken = async (api) => {


    const exchange = new ccxt.latoken({
        "apiKey": api.api_key,
        "secret": api.api_secret,
    })



    const orderbook = [];
    return orderbook;


};


const getOrderBook_Bittrex = async (api) => {


    const exchange = new ccxt.bittrex({
        "apiKey": api.api_key,
        "secret": api.api_secret,
    })

    const orderbook = [];
    return orderbook;


};

module.exports.Latoken = getOrderBook_Latoken;
module.exports.Bittrex = getOrderBook_Bittrex;
module.exports.Kucoin = getOrderBook_Kucoin;
module.exports.doMain = doMain;








