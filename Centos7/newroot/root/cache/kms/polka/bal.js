const { ApiPromise, WsProvider } = require('@polkadot/api');
const provider = new WsProvider('wss://room-house.com:8402/');
const args = require('minimist')(process.argv.slice(2));
const Alice = args['address'];

//const Alice = '5Cz7dPxsaDZY4PVUhgh8tiTbF2XavtPd7nwzJkhbsxFsJG2e';
//const ADDR1 = '5G3hGwV1XxQV16XL8MzV4br9KJ8wQ548Wf6YC7ScSeRbGCku';

async function main () {
  // Create an await for the API
  const api = await ApiPromise.create({ provider });

  const unsub = await api.query.system.account.multi([Alice], (balances) => {
    const [{ data: balance0 }] = balances;

    console.log(`${balance0.free}`);
    unsub();
    process.exit(0);
  });

}

main().catch(console.error);
