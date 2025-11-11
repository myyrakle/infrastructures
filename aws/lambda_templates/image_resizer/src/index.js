const http = require('http');
const https = require('https');
const querystring = require('querystring');
const sharp = require('sharp');
const urlencode = require('urlencode'); 

const aws = require('aws-sdk');
const S3 = new aws.S3();

// 이미지 사이즈로 축소
async function toSmallSize(image) {
	const resized = image.resize({ width: 140, height: 140 });
	
	return resized;
}

const BUCKET_NAME = 'metaverse2-community-image';

exports.handler = async (event, context, callback) => {
	const response = event.Records[0].cf.response;
	
	try {
		console.log('Response status code :%s', response.status);
	
		// 이미 리사이징된 파일이 저장되어있지 않을 경우
		if (response.status == 404 || response.status == 403) {
			const request = event.Records[0].cf.request;
			
			const requestUri = urlencode.decode(request.uri).replace('/', ''); // 첫번째 슬래시 제거
			const uri = requestUri.replace('resize/', ''); // resize prefix 제거
			
			console.log('requestUri: ', requestUri);
			
			const resizeType = uri.split('/')[0];
			const originUri = uri.replace(resizeType+'/', '');
			
			console.log('resizeType: ', resizeType);
			console.log('originUri: ', originUri);
	
			switch(resizeType) {
                // /resize/small/... 케이스 처리
				case 'small': {
					const data = await S3.getObject({
						Bucket: BUCKET_NAME,
						Key: originUri,
					}).promise();
					
					let image = sharp(data.Body);
					const metadata = await image.metadata();
					const format = metadata.format;
					
					const mimeType ='image/' + format;
					
					image = await toSmallSize(image)
					
					const buffer = await image.toBuffer();
					
          // 백업이 필요하다면 resize 경로에 저장. 하지 않더라도 캐싱 자체는 됨. 선택사항
					// await S3.upload({
			        //     Body: buffer,
			        //     Bucket: '...',
			        //     Key: requestUri,
			        //     ContentType: mimeType,
			        //     ACL: 'public-read',
			        // }).promise();
			
					// generate a binary response with resized image
					response.status = 200;
					response.body = buffer.toString('base64');
	        		response.bodyEncoding = 'base64';
	        		response.headers['content-type'] = [{ key: 'Content-Type', value: mimeType }]
					callback(null, response);
					
					break;
				} 
				default: {
					callback(null, response);
					break;
				}
			}
		} else {
			callback(null, response);
		}
	} 
	catch(error) {
		console.log('!! ERROR');
		console.error(error);
		callback(null, response);
	}
};
