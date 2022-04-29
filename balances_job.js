require('dotenv').config();
const pooling = require('./pooling.js');
const logger = require('./logger').logger;
const get_balances = require('./get_balances.js');
const get_my_trades = require('./get_my_trades.js');
const get_orderbook = require('./get_orderbook.js');
const set_price_in_usdt = require('./set_price_in_usdt.js');













let pool;


const insertMyTrades = async (conn, apis) => {

  const insertMyTrades = "INSERT IGNORE INTO my_trades (id_api, trade_id, symbol, fee_cost, fee_currency, fee_rate, price, amount, cost, datetime, side, order_id, taker_or_maker, type, timestamp) VALUES ?"
  let mytrades = await get_my_trades.doMain(apis);


  const insertedMyTrades = await conn.query(insertMyTrades, [mytrades]);
  return insertedMyTrades.affectedRows;




}

const insertOrderBook = async (conn, apis) => {

  const insertOrderBook = "INSERT INTO orderbook (sequence, symbol, side, price, amount, datetime) VALUES ?"

  let orderbook = await get_orderbook.doMain(apis);


  const insertedOrderBook = await conn.query(insertOrderBook, [orderbook]);
  return insertedOrderBook.affectedRows;




}
















const doMain = async () => {
  try {

    pool = pool || await pooling.getPool();
    const conn = await pool.getConnection();
    const apis = await conn.query("SELECT * FROM apis");

    const inserted_new_trades = await insertMyTrades(conn, apis);
    logger.info("INSERTED" + " " + inserted_new_trades + " " + "new trades");


    await conn.query("CALL drop_and_create_table_balances_job()");



    let balances = await get_balances.doMain(apis);



    const INSERT = "INSERT IGNORE INTO balances_job (id_api, address, currency, balance, inserted_at) VALUES ?"
    const insert = await conn.query(INSERT, [balances]);
    console.log(insert.affectedRows);


    await conn.query("CALL balances_job()");
    await conn.query("CALL update_variations()");
    const updated_price_in_usdt = await set_price_in_usdt.doMain(conn);
    logger.info("UPDATED" + " " + updated_price_in_usdt + " " + "price_in_usdt");

    await conn.query("CALL drop_and_create_table_dashboard_base_24h()");



    
    conn.release();


    pool.end();
    logger.info("INSERTED" + " " + insert.affectedRows + " " + "new balances");
    console.log('OK :)');

  }
  catch (err) {
    console.log(err);
    logger.error(err);
  }


}





doMain();







