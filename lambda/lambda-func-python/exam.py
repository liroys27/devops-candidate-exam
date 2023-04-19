import requests
import base64
import os
import json

def get_decoded_response(response):
    json_obj = json.loads(response.content)
    log_result_b64 = json_obj.get("log_result")
    decoded_bytes = base64.b64decode(log_result_b64)
    decoded_string = decoded_bytes.decode('utf-8')
    return decoded_string

def lambda_handler(event, context):
      #Vars
      url = 'https://2xfhzfbt31.execute-api.eu-west-1.amazonaws.com/candidate-email_serverless_lambda_stage/data'
      headers = {'X-Siemens-Auth': 'test'}
      #subnet_id = os.environ.get("snid")
      payload = {
            "subnet_id": subnet_id,
            "name": "Liron Shemer",
            "email": "liron.shemer@siemens.com"
          }
      response = requests.post(url, headers=headers, json=payload)
      print("Response original content:", response.content)
      decoded_string = get_decoded_response(response)
      print(f'Decoded String: {decoded_string}')

        


