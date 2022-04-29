const kucoin_api = require('./apis/kucoin-node-api/kucoin')
const utc = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
const ccxt = require('./apis/ccxt-master/ccxt.js');
const BigNumber = require('bignumber.js');




const doMain = async (apis) => {

    let balances = [];

    for (let i = 0; i < apis.length; i++) {

        let api = apis[i];

        if (api.exchange.toUpperCase() === "KUCOIN") {
            balances = balances.concat(await getBalances_Kucoin(api));


        };

        if (api.exchange.toUpperCase() === "LATOKEN") {
            balances = balances.concat(await getBalances_LaToken(api));


        };

        if (api.exchange.toUpperCase() === "BITTREX") {
            balances = balances.concat(await getBalances_Bittrex(api));


        };


    };

    return balances;


}


const getBalances_LaToken = async (api) => {


    const exchange = new ccxt.latoken({
        'enableRateLimit': true,
        'verbose': process.argv.includes('--verbose'),
        'apiKey': api.api_key,
        'secret': api.api_secret,
    });

    const balances = [];
    if (exchange.checkRequiredCredentials(false)) {

        const data = await exchange.fetchBalance();



        for (let i = 0; i < data.length; i++) {

            let total = (BigNumber(data[i].available).plus(BigNumber(data[i].blocked))).toFixed(20);
            balances.push([api.id_api, data[i].id, data[i].currency, total, utc]);
        };





    };
    return balances;

};

const getBalances_Kucoin = async (api) => {


    const config = {
        apiKey: api.api_key,
        secretKey: api.api_secret,
        passphrase: api.api_passphrase,
        environment: 'live',
    };
    kucoin_api.init(config);


    const r = await kucoin_api.getAccounts();
    const data = r.data;


    const balances = [];

    for (let i = 0; i < data.length; i++) {

        balances.push([api.id_api, data[i].id, data[i].currency, data[i].balance, utc]);

    };

    return balances;
};



const getBalances_Bittrex = async (api) => {


    const exchange = new ccxt.bittrex({
        "apiKey": api.api_key,
        "secret": api.api_secret,
    })

    const data = await exchange.fetchBalance();

    const balances = [];

    for (let i = 0; i < data.length; i++) {

        balances.push([api.id_api, api.id_api.toString() + data[i].currencySymbol, data[i].currencySymbol, data[i].total, utc]);

    };

    return balances;

};


module.exports.doMain = doMain;





