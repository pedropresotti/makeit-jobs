const ccxt = require('./apis/ccxt-master/ccxt.js');


const doMain = async (apis) => {


    let mytrades = [];

    for (let i = 0; i < apis.length; i++) {
        let api = apis[i];

        if (api.exchange.toUpperCase() === "KUCOIN") {
            mytrades = mytrades.concat(await getMyTrades_Kucoin(api));

        };


        if (api.exchange.toUpperCase() === "BITTREX") {
            mytrades = mytrades.concat(await getMyTrades_Bittrex(api));

        };

        if (api.exchange.toUpperCase() === "LATOKEN") {
            mytrades = mytrades.concat(await getMyTrades_Latoken(api));

        };



    }

    return mytrades;




}


const getMyTrades_Kucoin = async (api) => {


    const exchange = new ccxt.kucoin({
        "apiKey": api.api_key,
        "secret": api.api_secret,
        "password": api.api_passphrase,
    })


    const mytrades = [];

    const response = await exchange.fetchMyTrades();
    for (let i = 0; i < response.length; i++) {
        let r = response[i];
        let trade_id = r.info.tradeId;
        let symbol = r.symbol;
        let fee_cost = r.fee.cost;
        let fee_currency = r.fee.currency;
        let fee_rate = r.fee.rate;
        let price = r.price;
        let amount = r.amount;
        let cost = r.cost;
        let datetime = r.datetime;
        let side = r.side;
        let order_id = r.info.orderId;
        let taker_or_maker = r.takerOrMaker;
        let type = r.type;
        let timestamp = r.timestamp;
        mytrades.push([api.id_api, trade_id, symbol, fee_cost, fee_currency, fee_rate, price, amount, cost, datetime, side, order_id, taker_or_maker, type, timestamp]);

    }

    return mytrades;


};


const getMyTrades_Latoken = async (api) => {


    const exchange = new ccxt.latoken({
        "apiKey": api.api_key,
        "secret": api.api_secret,
    })


    const mytrades = [];

    const response = await exchange.fetchMyTrades();
    for (let i = 0; i < response.length; i++) {
        let r = response[i];
        let trade_id = r.info.id;
        let symbol = r.symbol;
        let fee_cost = r.fee.cost;
        let fee_currency = r.fee.currency;
        let fee_rate = null;
        let price = r.price;
        let amount = r.amount;
        let cost = r.cost;
        let datetime = r.datetime;
        let side = r.side;
        let order_id = r.info.order;
        let taker_or_maker = r.takerOrMaker;
        let type = null;
        let timestamp = r.timestamp;
        mytrades.push([api.id_api, trade_id, symbol, fee_cost, fee_currency, fee_rate, price, amount, cost, datetime, side, order_id, taker_or_maker, type, timestamp]);

    }

    return mytrades;


};


const getMyTrades_Bittrex = async (api) => {


    const exchange = new ccxt.bittrex({
        "apiKey": api.api_key,
        "secret": api.api_secret,
    })

    const mytrades = [];

    const response = await exchange.fetchMyTrades();
    for (let i = 0; i < response.length; i++) {
        let r = response[i];
        let trade_id = r.id;
        let symbol = r.symbol;
        let fee_cost = r.fee.cost;
        let fee_currency = r.fee.currency;
        let fee_rate = null;
        let price = r.price;
        let amount = r.amount;
        let cost = r.cost;
        let datetime = r.datetime;
        let side = r.side;
        let order_id = r.id;
        let taker_or_maker = null;
        let type = r.type;
        let timestamp = r.timestamp;
        mytrades.push([api.id_api, trade_id, symbol, fee_cost, fee_currency, fee_rate, price, amount, cost, datetime, side, order_id, taker_or_maker, type, timestamp]);

    }

    return mytrades;


};

module.exports.doMain = doMain;








