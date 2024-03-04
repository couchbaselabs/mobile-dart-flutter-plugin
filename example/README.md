
### Application Configuration

In the provided application, the following configuration parameters are essential. The IP address `192.168.0.116` serves as our designated host, while `examplechat` represents the Sync Gateway database name.

```
ws://192.168.0.116:4984/examplechat
```

Ensure the alignment of the scope `chat` within the example application and the designation of `message` is congruent with your chosen scope and collections configuration on the Couchbase server.

```
.createCollection('message', 'chat')
```

Update the username and password in the application for secure access.

```
username: 'bob',
password: '12345'
```

It is imperative to customize these values to align with your specific configuration requirements.

### CORS Deactivation for Web Testing

During the testing phase of the web application, it is advised to disable Cross-Origin Resource Sharing (CORS). Execute the following command when launching the web application:

``` 
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

This command ensures the smooth operation of the web application by temporarily deactivating CORS, allowing for a comprehensive testing environment. Adjust the command as needed based on your specific testing requirements.