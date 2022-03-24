require('dotenv').config()
const pooling = require('./pooling.js');
const util = require('util');
const fs = require('fs');
const readFile = util.promisify(fs.readFile);
const kucoin_api = require('./kucoin-node-api/kucoin')
const utc = new Date().toISOString().replace(/T/, ' ').replace(/\..+/, '');
const logger = require('./logger').logger;


let pool;
const doMain = async () => {
  try {

    
    pool = pool || await pooling.getPool();
    let conn = await pool.getConnection();
   

   
    conn.query(await readFile('./CREATE_TABLE_BALANCES_JOB.sql', 'utf8'));



    let balances = [];
    const apis = await conn.query('SELECT * FROM apis');
    for (let i = 0; i < apis.length; i++) {

      let api = apis[i];

      if (api.exchange.toUpperCase() === "KUCOIN") {
        balances = balances.concat(await getBalancesKucoin(api));


      }


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
    logger.error(err);
  }


}

doMain();



const getBalancesKucoin = async (api) => {


  let config = {
    apiKey: api.api_key,
    secretKey: api.api_secret,
    passphrase: api.api_passphrase,
    environment: 'live',
  }
  kucoin_api.init(config);


  let r = await kucoin_api.getAccounts();
  var data = r.data;


  const balances = [];

  for (var i = 0; i < data.length; i++) {

    balances.push([api.id_api, data[i].id, data[i].currency, data[i].balance, utc]);

  }

  return balances;
}