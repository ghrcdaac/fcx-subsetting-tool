# install lambda packages to create lambda layers

yes | pip3 install -r ./lambda_layers/websocket_client/requirement.txt --target ./lambda_layers/websocket_client/python/
yes | pip3 install -r ./lambda_layers/marshmallow_json/requirement.txt --target ./lambda_layers/marshmallow_json/python/
yes | pip3 install -r ./lambda_layers/xarr_s3fs_h5ncf/requirement.txt --target ./lambda_layers/xarr_s3fs_h5ncf/python/
yes | pip3 install -r ./lambda_layers/xarr_scipy/requirement.txt --target ./lambda_layers/xarr_scipy/python/