import boto3
import json

def lambda_handler(event, context):
    """
    This lambda function acts as a proxy lambda.
    It will recieve the inputs from the api gateway.
    Then it will invoke another AWS lambda function,
    along with necessary the payloads.
    """
    
    body = json.loads(event['body']) # is a string
    payloadStr = json.dumps(body)

    client = boto3.client('lambda')

    # The lambda sanjog-subsetting-fcx subsets all the subsets at once
    # client.invoke(
    #     FunctionName='sanjog-subsetting-fcx',
    #     InvocationType="Event",
    #     Payload=payloadStr
    # )
    
    client.invoke(
        FunctionName='sanjog-subsetting-fcx-CRS',
        InvocationType="Event",
        Payload=payloadStr
    )    

    client.invoke(
        FunctionName='sanjog-subsetting-fcx-FEGS',
        InvocationType="Event",
        Payload=payloadStr
    )
    
    client.invoke(
        FunctionName='sanjog-subsetting-fcx-GLM',
        InvocationType="Event",
        Payload=payloadStr
    )
    
    client.invoke(
        FunctionName='sanjog-subsetting-fcx-LIP',
        InvocationType="Event",
        Payload=payloadStr
    )
    
    client.invoke(
        FunctionName='sanjog-subsetting-fcx-LIS',
        InvocationType="Event",
        Payload=payloadStr
    )
    
    client.invoke(
        FunctionName='sanjog-subsetting-fcx-LMA',
        InvocationType="Event",
        Payload=payloadStr
    )
    
    responseBody = {
                'message': "Subsetting lambda function invoked.",
                'subsetDir': body['body']['subDir']
            }

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST,GET'
        },
        'body': json.dumps(responseBody)
    }