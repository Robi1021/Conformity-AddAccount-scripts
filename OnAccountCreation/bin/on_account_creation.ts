#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from '@aws-cdk/core';
import { OnAccountCreationStack } from '../lib/on_account_creation-stack';

const app = new cdk.App();
new OnAccountCreationStack(app, 'OnAccountCreationStack');
