import boto3
import json

def lambda_handler(event, context):
    """
    This lambda function acts as a proxy lambda.
    It will recieve the inputs from the api gateway.
    Then it will invoke another AWS lambda function,
    along with necessary the payloads.
    """
    
    body = event['body'] # is a string
    payloadStr = json.dumps(body) # is a string. so not really necessary

    client = boto3.client('lambda')
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
    
    return {
        'statusCode': 200,
        'body': "Subsetting lambda function invoked."
    }

    
