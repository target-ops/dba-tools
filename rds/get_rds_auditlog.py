import boto3
import datetime
import sys
import time
import csv

def initialize_boto3_cloudwatch():
    """
    Initializes a boto3 CloudWatch client,
    using environment variables to authenticate.
    """
    return boto3.client('logs')

def get_cloudwatch_log_group_contents(cw, log_group_name, start_time, end_time):
    query = "fields @timestamp, @message | sort @timestamp asc"

    start_query_response = cw.start_query(
        logGroupName=log_group_name,
        startTime=start_time,
        endTime=end_time,
        queryString=query,
    )

    query_id = start_query_response['queryId']

    response = None
    lines = list()

    while response == None or response['status'] == 'Running':
        print('.', end='', flush=True)
        time.sleep(1)
        response = cw.get_query_results(
            queryId=query_id
        )
        for result in response['results']:
            for field in result:
                if field['field'] == '@message':
                    message = field['value']
                elif field['field'] == '@timestamp':
                    timestamp = field['value']
            lines.append(f'{timestamp},{message}')

    print()

    # It is unclear why but we receive lines twice
    # This sorting could consume a lot of memory. Consider using the bash sort -u command instead.                 
    lines = sorted(set(lines))

    print(f'Received {len(lines)} lines.')

    return lines

def timestamp_to_int(ts):
    """
    Converts a timestamp string in iso format to an integer.
    """
    return int(datetime.datetime.strptime(ts, "%Y-%m-%dT%H:%M:%S.%f%z").timestamp())

def print_usage():
    """
    Prints usage details.
    """
    print("""Usage: python download_audit_log.py <log_group_name> <start_time> <end_time> <full_log_file_name> <queries_file_name>
          
          Example: python download_audit_log.py /aws/rds/cluster/INSTANCE/audit 2023-07-01T00:00:00.00+00:00 2023-07-18T23:59:59.99+00:00 full.log queries.sql""")

def decode_str(str):
    """
    Decode unicode string
    """
    return bytes(str, "utf-8").decode("unicode_escape")

def extract_csv_field(str, field):
    """
    Extract a field from a CSV string
    """
    return ','.join(list(csv.reader([str], delimiter=','))[0][field:])

def main():
    """
    Downloads the contents of a CloudWatch log group.
    Expects 3 command-line arguments:
    a. log group name
    b. start time
    c. end time
    d. full log file name
    e. only queries file name

    Check that arguments are not empty and valid.
    Print usage details if there is a problem with arguments.
    Otherwise, download the log group contents.
    """
    if len(sys.argv) != 6:
        print_usage()
        return

    log_group_name = sys.argv[1]
    start_time = timestamp_to_int(sys.argv[2])
    end_time = timestamp_to_int(sys.argv[3])
    full_log_file_name = sys.argv[4]
    queries_file_name = sys.argv[5]

    if log_group_name == "" or start_time == "" or end_time == "" or full_log_file_name == "" or queries_file_name == "":
        print_usage()
        return

    cw = initialize_boto3_cloudwatch()
    
    contents = get_cloudwatch_log_group_contents(cw, log_group_name, start_time, end_time)
    with open(full_log_file_name, "w") as full_log_file, open(queries_file_name, "w") as queries_file:
        for line in contents:
            full_log_file.write(line + "\n")
            
            if not line.endswith(',0'):
                continue

            line = line[:-2] # Strip ",0" from end of line
            query = extract_csv_field(line, 9)
            query = query[1:-1] # Strip "'" from start and end (Not using the strip() method because there could be more than one "'" at the end)
            query = decode_str(query) + ';'
            queries_file.write(query + "\n")

if __name__ == "__main__":
    main()