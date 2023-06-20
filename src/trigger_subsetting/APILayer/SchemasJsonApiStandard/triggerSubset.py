from marshmallow_jsonapi import Schema, fields
from marshmallow import validate

# Serializers, before transmitting data
class SubsetTriggerSerializerSchema(Schema):
    id = fields.Str(dump_only=True)
    message = fields.Str()
    subsetDir = fields.Str()

    class Meta:
        type_ = "subset_trigger_response"
        
# De-Serializers, after receiving data
class SubsetTriggerDeserializerSchema(Schema):
    id = fields.Str(dump_only=True)
    subDir = fields.Str(required=True)
    date = fields.Str(required=True, validate=validate.Length(6))
    Start = fields.Str(required=True, validate=validate.Length(6))
    End = fields.Str(required=True, validate=validate.Length(6))
    wsTokenId = fields.Str(required=True)
    
    class Meta:
        type_ = "subset_trigger_request"