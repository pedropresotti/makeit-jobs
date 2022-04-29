import { CoinGeckoClient } from 'coingecko-api-v3';



export const token_to_usdt = async (coinId, date) => {


  const client = new CoinGeckoClient({
    timeout: 10000,
    autoRetry: true,
  });;
  let result;
  const geckoDate = toGeckoDate(date);
  if (isToday(date)) {
    result = await client.coinId({ id: coinId, localization: false });
  }
  else {
    result = await client.coinIdHistory({ id: coinId, date: geckoDate, localization: false });
  }



  return result.market_data.current_price.usd;


};

export const euro_to_usdt = async (date) => {


  const client = new CoinGeckoClient({
    timeout: 10000,
    autoRetry: true,
  });;

  let result;
  const geckoDate = toGeckoDate(date);
  if (isToday(date)) {
    result = await client.coinId({ id: 'tether', localization: false });
  }
  else {
    result = await client.coinIdHistory({ id: 'tether', date: geckoDate, localization: false });
  }
  return 1 / result.market_data.current_price.eur;


};

export const isToday = (date) => {

  const now = new Date();
  const now_utc = new Date(now.toUTCString().slice(0, -4));


  if (now_utc.getDate() === date.getDate() && now_utc.getMonth() === date.getMonth() && now_utc.getFullYear() === date.getFullYear()) {
    return true;
  }
  else {
    return false;
  }


}


export const toGeckoDate = (value) => {
  let day = ("0" + value.getDate()).slice(-2);
  let month = ("0" + (value.getMonth() + 1)).slice(-2);
  let year = value.getFullYear();


  const datestring = day + "-" + month + "-" + year;
  return datestring;
};