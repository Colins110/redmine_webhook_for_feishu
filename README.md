Redmine WebHook Plugin For FeiShu
======================

A Redmine plugin posts webhook to feishu on creating and updating tickets.

Thanks For [Redmine WebHook Plugin](https://github.com/suer/redmine_webhook)

Author
------------------------------
* @colin

Install
------------------------------
Type below commands:

    $ cd $RAILS_ROOT/plugins
    $ git clone https://github.com/Colins110/redmine_webhook_for_feishu.git
    $ rake redmine:plugins:migrate RAILS_ENV=production

Then, restart your redmine.

Requirements
------------------------------
* Redmine 4.0 or later


Skipping webhooks
------------------------------
When a webhook triggers a change via REST API, this would trigger another webhook.
If you need to prevent this, the API request can include the `X-Skip-Webhooks` header, which will prevent webhooks being triggered by that request.


Known Limitations
------------------------------

An update from context menu doesn't call a webhook event.
It is caused by a lack of functionality hooking in Redmine.
Please see https://github.com/suer/redmine_webhook/issues/4 for details.

This limitation has been affected on all Redmine versions includes 2.4, 2.6,
and 3.0. It is not fixed in end of April, 2015.


License
------------------------------
The MIT License (MIT)
Copyright (c) suer

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
