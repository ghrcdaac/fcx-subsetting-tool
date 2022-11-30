import boto3
import json
from SchemasJsonApiStandard.triggerSubset import SubsetTriggerDeserializerSchema, SubsetTriggerSerializerSchema
from .helper.staticData import default_datasets

def lambda_handler(event, context):
    """
    This lambda function acts as a proxy lambda.
    It will recieve the inputs from the api gateway.
    Then it will invoke another AWS lambda function,
    along with necessary the payloads.
    """
    
    body = json.loads(event) #dictonary
    # bodyStr = json.dumps(event) #string
    payload = {}
    payloadStr = ""

    # DESERIALIZE DATA
    try:
        SubsetTriggerDeserializerSchema().validate(body)
        payload = SubsetTriggerDeserializerSchema().load(body)
        neededInputData = {**default_datasets, **payload}
        payloadStr = json.dump(neededInputData)
    except Exception as err:
        # if any kind of error, return it as response.
        return {
            'statusCode': 400,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST,GET'
            },
            'body': err.messages
        }

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