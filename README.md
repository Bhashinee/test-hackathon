# test-hackathon

This scenario is about registering services in Consule and calling the relevant service endpoint by fetching the service data from the consule registry.

First of all, you need to have consule installed [https://learn.hashicorp.com/consul/getting-started/install], up and running in your machine.

Then we start the backend service. Once the service got started succesfully, we call the call the consule and register the service.

When a remote client wants to connect to the backend, it does a health check of the registered service with consule and request the ip if the service is up and running.
Then we send requests to the backend.
