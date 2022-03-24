const mysql = require('promise-mysql');


const getPool = async () => {
    
    if (process.platform === "win32" && process.env.NODE_ENV === "DEVELOPMENT") {
        return createDevelopmentTcpPool();
    }
    if (process.platform === "win32" && process.env.NODE_ENV === "PRODUCTION") {
        return createProductionTcpPool();
    }

    if (process.platform === "linux" && process.env.NODE_ENV === "PRODUCTION") {
        return createProductionSocketPool();
    }

    return null;


}



const createProductionSocketPool = async () => {
    return mysql.createPool({
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
        database: process.env.MYSQL_DATABASE,
        socketPath: process.env.MYSQL_SOCKETPATH_PRODUCTION,
        multipleStatements: true,
    });
};


const createProductionTcpPool = async () => {
    return mysql.createPool({
        host: process.env.MYSQL_HOST,
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
        database: process.env.MYSQL_DATABASE,
        port: process.env.MYSQL_PORT_PRODUCTION,
        multipleStatements: true,
    });
};

const createDevelopmentTcpPool = async () => {
    return mysql.createPool({
        host: process.env.MYSQL_HOST,
        user: process.env.MYSQL_USER,
        password: process.env.MYSQL_PASSWORD,
        database: process.env.MYSQL_DATABASE,
        port: process.env.MYSQL_PORT_DEVELOPMENT,
        multipleStatements: true,
    });
};


module.exports.getPool = getPool;