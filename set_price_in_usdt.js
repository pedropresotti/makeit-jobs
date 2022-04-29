const logger = require('./logger').logger;



const doMain = async (conn) => {


    const gecko_client = await import('./gecko.mjs');
    let updated;
    let changedRows = 0;


    let coins = await conn.query("SELECT DISTINCT balances_change_history.currency, gecko_coins.id, DATE(inserted_at) AS inserted_at FROM balances_change_history INNER JOIN gecko_coins ON balances_change_history.currency = gecko_coins.symbol WHERE currency NOT IN ('USDT', 'EUR', 'BTXCRD') AND price_in_usdt IS NULL");

    const update = 'UPDATE balances_change_history SET price_in_usdt = ? WHERE id > 0 AND currency = ? AND DATE(inserted_at) = ?'
    for (let i = 0; i < coins.length; i++) {
        let id = coins[i].id;
        let currency = coins[i].currency;
        let date = coins[i].inserted_at;



        let price_in_usdt = await gecko_client.token_to_usdt(id, date);

        logger.info(currency + ";" + formatDate(date) + ";" + "price_in_usdt: " + price_in_usdt)
        updated = await conn.query(update, [price_in_usdt, currency, date]);
        changedRows += updated.changedRows;

    }

    coins = await conn.query("SELECT DISTINCT currency, DATE(inserted_at) AS inserted_at FROM balances_change_history WHERE currency IN ('EUR') AND price_in_usdt IS NULL");
    for (let i = 0; i < coins.length; i++) {
        let currency = coins[i].currency;
        let date = coins[i].inserted_at;


        let price_in_usdt = await gecko_client.euro_to_usdt(date);


        logger.info(currency + ";" + formatDate(date) + ";" + "price_in_usdt: " + price_in_usdt)
        updated = await conn.query(update, [price_in_usdt, currency, date]);
        changedRows += updated.changedRows;

    }


    updated = await conn.query("UPDATE balances_change_history balan_hist SET balan_hist.price_in_usdt = 0.01 WHERE balan_hist.currency = 'BTXCRD' AND price_in_usdt IS NULL AND balan_hist.id > 0");
    changedRows += updated.changedRows;
    updated = await conn.query("UPDATE balances_change_history balan_hist SET balan_hist.price_in_usdt = 1 WHERE balan_hist.currency = 'USDT' AND price_in_usdt IS NULL AND balan_hist.id > 0");
    changedRows += updated.changedRows;

    return changedRows;

    




};
const formatDate = (value) => {
    let day = ("0" + value.getDate()).slice(-2);
    let month = ("0" + (value.getMonth() + 1)).slice(-2);
    let year = value.getFullYear();

    const datestring = year + "-" + month + "-" + day;
    return datestring;
};


module.exports.doMain = doMain;