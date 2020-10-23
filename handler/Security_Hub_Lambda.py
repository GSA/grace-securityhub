
import boto3
from botocore.exceptions import ClientError
import logging
import os

logging.basicConfig(level=logging.INFO)


def lambda_handler(event=None, context=None):

    sts_client = boto3.client('sts')

    # Call the assume_role method of the STSConnection object and pass the role
    # ARN and a role session name.
    assumed_role_object=sts_client.assume_role(
        RoleArn=os.environ['master_role_name'],
        RoleSessionName="AssumeRoleSession1"
    )

    # From the response that contains the assumed role, get the temporary 
    # credentials that can be used to make subsequent API calls
    credentials=assumed_role_object['Credentials']


    client = boto3.client('organizations', 
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'], 
    )

    # Grabs All Accounts from Master Payer/tenant ou
    list_acct_response = client.list_accounts_for_parent(
        ParentId=os.environ['organizational_ou'],
        MaxResults=20 #need to fix/account for more than 20
        )
    logging.info("Gathering Tenant Accounts")
    logging.info(list_acct_response['Accounts'][0]['Id'])

    paas_accounts = []

    # Strips tenant Account Numbers into list only
    while list_acct_response['Accounts']:
        paas_accounts.append (list_acct_response['Accounts'][0]['Id'])
        list_acct_response['Accounts'].pop(0)

    paas_accounts.remove(os.environ['hub_account'])  #Removes G-GRACE Account from results
    logging.info("Proccessing Tenant Accounts")
    logging.info(paas_accounts)


    sechub_client = boto3.client('securityhub')

    list_members_response = sechub_client.list_members(
        OnlyAssociated=True|False,
        MaxResults=10,
        #NextToken='next'
    )

    sechub_accounts = []

    # Adds SecHub Tenant Accounts from list and identifies accounts that require invites
    while list_members_response['Members']:

        sechub_accounts.append (list_members_response['Members'][0]['AccountId'])
        list_members_response['Members'].pop(0)
    logging.info("Gathering Active SecHub Members")
    logging.info(sechub_accounts)
    #print(sechub_members['Members'][0]['AccountId']['Email'])

    set1=set(paas_accounts)
    set2=set(sechub_accounts)

    deltaset = set1-set2
    deltalist = list(deltaset)

    logging.info("Accounts to recieve invites")
    logging.info(deltaset)

    # Invites all accounts from tenant ou that have not been joined to the Master SecHub Account
    while deltalist:

     describe_account_response = client.describe_account(
        AccountId=deltalist[0]

    )
     response = sechub_client.create_members(
        AccountDetails=[
            {
                'AccountId': describe_account_response['Account']['Id'], 
                'Email': describe_account_response['Account']['Email']
            }
        ]
    )
     invite_response = sechub_client.invite_members(
        AccountIds=[deltalist[0]]
    )


     assumed_role_object=sts_client.assume_role(
        RoleArn='arn:aws:iam::' + deltalist[0] + ':role/OrganizationAccountAccessRole', #standarize the role name for tenants
        RoleSessionName="AssumeRoleSession2"
    )

     credentials=assumed_role_object['Credentials']

     sechub_client_tenant = boto3.client('securityhub', 
        aws_access_key_id=credentials['AccessKeyId'],
        aws_secret_access_key=credentials['SecretAccessKey'],
        aws_session_token=credentials['SessionToken'], 
    )

     invitations_response = sechub_client_tenant.list_invitations(
        MaxResults=10,
        #NextToken='string'
    )

     logging.info("Member Status")
     logging.info(invitations_response)

     accept_invitation_response = sechub_client_tenant.accept_invitation(
        MasterId=invitations_response['Invitations'][0]['AccountId'],
        InvitationId=invitations_response['Invitations'][0]['InvitationId']
    )
     logging.info("Member Invitation")
     logging.info(accept_invitation_response)
 

     deltalist.pop(0)

    list_members_response = sechub_client.list_members(
        OnlyAssociated=True|False,
        MaxResults=10,
        #NextToken='next'
    )

    logging.info("Status")
    logging.info(list_members_response)

