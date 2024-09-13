from enum import Enum
import os
import json

from requests.adapters import HTTPAdapter
from requests.packages.urllib3.util.retry import Retry
from requests.sessions import Session
from requests.exceptions import RequestException



class HTTPMethod(Enum):
    GET = "GET"
    POST = "POST"
    DELETE = "DELETE"


def request_with_retry(url, headers={}, payload={}, method=HTTPMethod.GET, verbose=True):
    """
    Sends an HTTP request to the specified URL with retry logic.

    Args:
        url (str): The URL to send the request to.
        headers (dict, optional): The headers to include in the request. Defaults to {}.
        payload (dict, optional): The payload to include in the request. Defaults to {}.
        method (str, optional): The HTTP method to use for the request. Defaults to HTTPMethod.GET.
        verbose (bool, optional): Whether to print verbose output. Defaults to False.

    Returns:
        dict: The JSON response from the request, if successful. Otherwise, an empty dictionary.

    Raises:
        Exception: If the specified HTTP method is not supported.
        requests.exceptions.RequestException: If an error occurs while sending the request.
    """

    session = Session()
    retry_strategy = Retry(
        total=6,
        # Delay between retries (exponential backoff)
        backoff_factor=0.5,  
        # HTTP status codes to retry
        status_forcelist=[500, 502, 503, 504, 505],
    )
    adapter = HTTPAdapter(max_retries=retry_strategy)
    session.mount("http://", adapter)
    session.mount("https://", adapter)
    try:
        response = {}
        if method == HTTPMethod.POST:
            response = session.post(url, json=payload, headers=headers, timeout=4)
        elif method == HTTPMethod.GET:
            response = session.get(url, json=payload, headers=headers, timeout=4)
        elif method == HTTPMethod.DELETE:
            response = session.delete(url, json=payload, headers=headers, timeout=4)
        else:
            raise Exception("Method Not supported")
        
        response.raise_for_status()        
        if response.status_code > 400:
            if verbose:
                print(f"Request {method} {url} response {response.status_code} unsuccesful .")
            return {}
        elif response.content:
            # Assuming the response is in JSON format
            if verbose:
                print(f"Request {method} {url} Result {response.json()}.")
            return response.json()
        else:
            if verbose:
                print(f"Request {url} Empty response received.")
            return {}
    except RequestException as e:
        if verbose:
            print(f"Request {url} \n failed with: {repr(e)}")
        raise e


def lambda_handler(event, context):
    """
    Handles the Lambda function invocation.

    Args:
        event (dict): The event data passed from Cloudwatch to the Lambda function.
        context (object): The runtime information of the Lambda function.

    Returns:
        dict: The response object containing the status code and body.

    Raises:
        Exception: If there is an error processing the event.

    """
    
    if event is None:
        return {
            'statusCode': 400,
            'body': 'null event object provided'
        }
    try:

        # Extract the relevant data from the alarm
        alarm_name = event["alarmData"].get("alarmName")
        alarm_description = event["alarmData"]["configuration"].get("description")
        region = event["region"]
        new_state = event["alarmData"]["state"].get("value")
        reason = event["alarmData"]["state"].get("reason")
        timestamp = event["alarmData"]["state"].get("timestamp")
        # Construct the message to be sent
        message = {
            "Message": f"Alarm Time: {timestamp}\nAlarm Name: {alarm_name}\nDescription: {alarm_description}\nState: {new_state}\nReason: {reason}\nRegion: {region}"
        }

        # Send the message to Slack
        webhook_url = os.environ['WEBHOOK']

        response_json = request_with_retry(url=webhook_url, payload=message, method=HTTPMethod.POST)
        print(f"Message sent to Slack. Content: {message}")# Response: {response.text}")
    except Exception as e:    
        print(f"Error: {repr(e)} ")
        return {
            'statusCode': 500,
            'body': f'Error processing the event\n {repr(e)}'
        }
    return {
        'statusCode': 200,
        'body': json.dumps(f'Message: \n{message}\n sent to Slack successfully. Response: {response_json}')
    }

## Uncomment to Test the function locally
#event_str = '''
#{
#  "source": "aws.cloudwatch",
#  "alarmArn": "arn:aws:cloudwatch:us-east-1:444455556666:alarm:lambda-demo-metric-alarm",
#  "accountId": "444455556666",
#  "time": "2023-08-04T12:36:15.490+0000",
#  "region": "us-east-1",
#  "alarmData": {
#    "alarmName": "lambda-demo-metric-alarm",
#    "state": {
#      "value": "ALARM",
#      "reason": "test",
#      "timestamp": "2023-08-04T12:36:15.490+0000"
#    },
#    "previousState": {
#      "value": "INSUFFICIENT_DATA",
#      "reason": "Insufficient Data: 5 datapoints were unknown.",
#      "reasonData": "{\\"version\\":\\"1.0\\",\\"queryDate\\":\\"2023-08-04T12:31:29.591+0000\\",\\"statistic\\":\\"Average\\",\\"period\\":60,\\"recentDatapoints\\":[],\\"threshold\\":5.0,\\"evaluatedDatapoints\\":[{\\"timestamp\\":\\"2023-08-04T12:30:00.000+0000\\"},{\\"timestamp\\":\\"2023-08-04T12:29:00.000+0000\\"},{\\"timestamp\\":\\"2023-08-04T12:28:00.000+0000\\"},{\\"timestamp\\":\\"2023-08-04T12:27:00.000+0000\\"},{\\"timestamp\\":\\"2023-08-04T12:26:00.000+0000\\"}]}",
#      "timestamp": "2023-08-04T12:31:29.595+0000"
#    },
#    "configuration": {
#      "description": "Metric Alarm to test Lambda actions",
#      "metrics": [
#        {
#          "id": "1234e046-06f0-a3da-9534-EXAMPLEe4c",
#          "metricStat": {
#            "metric": {
#              "namespace": "AWS/Logs",
#              "name": "CallCount",
#              "dimensions": {
#                "InstanceId": "i-12345678"
#              }
#            },
#            "period": 60,
#            "stat": "Average",
#            "unit": "Percent"
#          },
#          "returnData": true
#        }
#      ]
#    }
#  }
#}
#'''
#
#
#print(lambda_handler(json.loads(event_str), {}))
