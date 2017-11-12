fuser -k 3000/tcp
cd /home/bitnami/apps/myApp/dist/
mkdir -p logs
npm -v
npm install
node app.server.prod2.js --NODE_ENV=staging> /dev/null 2> /dev/null < /dev/null &