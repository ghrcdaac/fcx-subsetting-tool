from websocket import create_connection
import json

# class declaration
class WSConnect:
    """
    Use this for a two way asynchronous communication bewteen frontend and lambda backend.
    Messages are seperated on the basis of wsTokenId.
    So, if a clients and the lambda serverless using this class has the same wsToken, both can communicate privately.
    Note: the ws api gateway should handle this functionlity.
    """

    def __init__(self, wsurl, wsTokenId):
        self.ws = create_connection(wsurl)
        self.afterConnect(wsTokenId)
        
    def afterConnect(self, wsTokenId):
        afterConnectMsg = { "action": "afterconnect", "wsTokenId": wsTokenId }
        self.ws.send(json.dumps(afterConnectMsg))

    def sendMessage(self, message):
        """sends message to the connection with the same token id 

        Args:
            message (_type_): json/hash
        """
        msg_format = { "action": "sendmessage", "data": json.dumps(message) }
        self.ws.send(json.dumps(msg_format))
    
    def close(self):
        self.ws.close()