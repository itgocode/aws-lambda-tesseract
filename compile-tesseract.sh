# Spin up and enter the docker container on your machine with the following command:
# docker run -it lambci/lambda:build-nodejs10.x bash


# Then run the rest of the commands inside

# install basic stuff required for compilation
yum install -y aclocal autoconf automake cmakegcc freetype-devel gcc gcc-c++ \
	git lcms2-devel libjpeg-devel libjpeg-turbo-devel autogen autoconf libtool \
	libpng-devel libtiff-devel libtool libwebp-devel libzip-devel make zlib-devel

# leptonica
cd ~
git clone https://github.com/DanBloomberg/leptonica.git
cd leptonica/
./autogen.sh
./configure
make
make install

# tesseract
cd ~
git clone https://github.com/tesseract-ocr/tesseract.git
cd tesseract
git checkout 4.1.0
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
./autogen.sh
./configure
make
make install

cd ~
mkdir tesseract-standalone

# copy files
cd tesseract-standalone
cp /usr/local/bin/tesseract .
mkdir lib
cp /usr/local/lib/libtesseract.so.4 lib/
cp /lib64/libpng15.so.15 lib/
cp /lib64/libtiff.so.5 lib/
cp /lib64/libgomp.so.1 lib/
cp /lib64/libjbig.so.2.0 lib/
cp /usr/local/lib/liblept.so.5 lib/
cp /usr/lib64/libjpeg.so.62 lib/
cp /usr/lib64/libwebp.so.4 lib/
cp /usr/lib64/libstdc++.so.6 lib/

# copy training data
mkdir tessdata
cd tessdata
curl -L https://github.com/tesseract-ocr/tessdata_fast/raw/master/eng.traineddata --output eng.traineddata

# archive
cd ~

# trim unneeded ~ 15 MB
strip ./tesseract-standalone/**/*

tar -zcvf tesseract.tar.gz tesseract-standalone

# download from docker to local machine
# 21c27dc1bf5d is docker container id, you can look it up by running "docker ps"
docker cp 21c27dc1bf5d:/root/tesseract.tar.gz tt.tar.gz
