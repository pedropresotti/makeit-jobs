require('dotenv').config();
const pooling = require('./pooling.js');
const util = require('util');
const fs = require('fs');
const readFile = util.promisify(fs.readFile);
const logger = require('./logger').logger;
const get_balances = require('./get_balances.js');


let pool;
const doMain = async () => {
  try {



    pool = pool || await pooling.getPool();
    const conn = await pool.getConnection();



    conn.query(await readFile('./CREATE_TABLE_BALANCES_JOB.sql', 'utf8'));



    let balances = [];
    const apis = await conn.query('SELECT * FROM apis');
    for (let i = 0; i < apis.length; i++) {

      let api = apis[i];

      if (api.exchange.toUpperCase() === "KUCOIN") {
        balances = balances.concat(await get_balances.Kucoin(api));


      };

      if (api.exchange.toUpperCase() === "LATOKEN") {
        balances = balances.concat(await get_balances.LaToken(api));


      };

      if (api.exchange.toUpperCase() === "BITTREX") {
        balances = balances.concat(await get_balances.Bittrex(api));


      };


    };

    const INSERT = "INSERT IGNORE INTO balances_job (id_api, address, currency, balance, inserted_at) VALUES ?"

    const insert = await conn.query(INSERT, [balances]);
    console.log(insert.affectedRows);


    conn.query(await readFile('./balances_job.sql', 'utf8'));
    conn.query(await readFile('./CREATE_TABLE_overall_change_24h.sql', 'utf8'));


    conn.release();


    pool.end();
    logger.info(insert.affectedRows);

  }
  catch (err) {
    console.log(err);
    logger.error(err);
  }


}

doMain();







