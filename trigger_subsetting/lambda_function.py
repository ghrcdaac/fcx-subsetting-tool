import boto3
import json
from APILayer.SchemasJsonApiStandard.triggerSubset import SubsetTriggerDeserializerSchema, SubsetTriggerSerializerSchema
from APILayer.helper.staticData import default_datasets

def lambda_handler(event, context):
    """
    This lambda function acts as a proxy lambda.
    It will recieve the inputs from the api gateway.
    Then it will invoke another AWS lambda function,
    along with necessary the payloads.
    """
    body = json.loads(event["body"]) #dictonary
    payload = {}
    payloadStr = ""

    # DESERIALIZE DATA START
    validataionError = SubsetTriggerDeserializerSchema().validate(body)
    if (validataionError):
        # if any kind of error, return it as response.
        return {
            'statusCode': 400,
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'POST,GET'
            },
            'body': json.dumps(validataionError)
            }
    payload = SubsetTriggerDeserializerSchema().load(body) #deserilalize
    neededInputData = {**default_datasets, **payload}
    payloadStr = json.dumps(neededInputData)

    # DESERIALIZE DATA END

    client = boto3.client('lambda')

    # The lambda sanjog-subsetting-fcx subsets all the subsets at once
    # client.invoke(
    #     FunctionName='sanjog-subsetting-fcx',
    #     InvocationType="Event",
    #     Payload=payloadStr
    # )
    
    client.invoke(
        FunctionName="fcx-subsetting-CRS-worker",
        InvocationType="Event",
        Payload=payloadStr
    )    

    client.invoke(
        FunctionName="fcx-subsetting-FEGS-worker",
        InvocationType="Event",
        Payload=payloadStr
    )
    
    client.invoke(
        FunctionName="fcx-subsetting-GLM-worker",
        InvocationType="Event",
        Payload=payloadStr
    )
    
    client.invoke(
        FunctionName="fcx-subsetting-LIP-worker",
        InvocationType="Event",
        Payload=payloadStr
    )
    
    client.invoke(
        FunctionName="fcx-subsetting-LIS-worker",
        InvocationType="Event",
        Payload=payloadStr
    )
    
    client.invoke(
        FunctionName="fcx-subsetting-LMA-worker",
        InvocationType="Event",
        Payload=payloadStr
    )
    
    responseBody = {
                'message': "Subsetting lambda function invoked.",
                'subsetDir': payload['subDir']
            }

    # SERIALIZE DATA START
    serializedResponse = SubsetTriggerSerializerSchema().dumps(responseBody) #serialize
    # SERIALIZE DATA END

    return {
        'statusCode': 200,
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'POST,GET'
        },
        'body': serializedResponse
    }