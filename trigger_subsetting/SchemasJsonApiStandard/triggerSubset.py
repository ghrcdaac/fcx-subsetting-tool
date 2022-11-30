from marshmallow_jsonapi import Schema, fields
from marshmallow import validate

class SubsetTriggerResposneSchema(Schema):
    id = fields.Str(dump_only=True)
    message = fields.Str()
    subsetDir = fields.Str()

    class Meta:
        type_ = "subset_trigger_response"
        
class SubsetTriggerRequestSchema(Schema):
    id = fields.Str(dump_only=True)
    subDir = fields.Str(required=True)
    date = fields.Str(required=True, validate=validate.Length(6))
    Start = fields.Str(required=True, validate=validate.Length(6))
    End = fields.Str(required=True, validate=validate.Length(6))
    
    class Meta:
        type_ = "subset_trigger_request"