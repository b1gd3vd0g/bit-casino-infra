# Sync the S3 bucket with the latest version of Bit Casino's frontend.

rm -rf bc-fe
git clone https://github.com/b1gd3vd0g/bit-casino-frontend.git bc-fe
cd bc-fe
npm ci
npm run build
cd dist
aws s3 sync . s3://bitcasino.bigdevdog.com
cd ../..
rm -rf bc-fe
