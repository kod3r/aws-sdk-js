# Copyright 2011-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

AWS = require('../../lib/core')
require('../../lib/rest_xml_service')

describe 'AWS.RESTXMLService', ->

  operation = null

  MockRESTXMLService = AWS.util.inherit AWS.RESTXMLService,
    constructor: (config) ->
      this.serviceName = 'mockservice'
      AWS.RESTXMLService.call(this, config)

  beforeEach ->

    MockRESTXMLService.prototype.api =
      operations:
        sampleOperation:
          m: 'POST' # http method
          u: '/'    # uri
          i: null   # no params
          o: null   # no ouputs

    AWS.Service.defineMethods(MockRESTXMLService)

    operation = MockRESTXMLService.prototype.api.operations.sampleOperation

  svc = new MockRESTXMLService()

  it 'defines a method for each api operation', ->
    expect(typeof svc.sampleOperation).toEqual('function')

  describe 'buildRequest', ->

    buildRequest = (params) ->
      svc.buildRequest('sampleOperation', params)

    it 'returns an http request', ->
      req = svc.buildRequest('sampleOperation', {})
      expect(req.constructor).toBe(AWS.HttpRequest)

    describe 'http request method', ->

      it 'populates method from the operation', ->
        operation.m = 'GET'
        expect(buildRequest().method).toEqual('GET')

    describe 'http request uri', ->

      it 'populates uri from the operation', ->
        operation.u = '/path'
        expect(buildRequest().uri).toEqual('/path')

      it 'replaces param placeholders', ->
        operation.u = '/Owner/{Id}'
        operation.i = {Id:{l:'uri'}}
        expect(buildRequest({'Id': 'abc'}).uri).toEqual('/Owner/abc')

      it 'can replace multiple path placeholders', ->
        operation.u = '/{Id}/{Count}'
        operation.i = {Id:{l:'uri'},Count:{t:'i',l:'uri'}}
        expect(buildRequest({Id:'abc',Count:123}).uri).toEqual('/abc/123')

      it 'performs querystring param replacements', ->
        operation.u = '/path?id-param={Id}'
        operation.i = {Id:{l:'uri'}}
        expect(buildRequest({Id:'abc'}).uri).toEqual('/path?id-param=abc')

      it 'omits querystring when param is not provided', ->
        operation.u = '/path?id-param={Id}'
        operation.i = {Id:{l:'uri'}}
        expect(buildRequest().uri).toEqual('/path')
