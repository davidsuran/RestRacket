CREATE TABLE IF NOT EXISTS [Versions]
    ([Id] INTEGER, [Version] TEXT, UNIQUE([Id]));

CREATE TABLE IF NOT EXISTS [Requests]
    ([Id] INTEGER, [Url] TEXT, [UrlParams] TEXT, [Header] TEXT, [Body] TEXT, UNIQUE([Id]));

CREATE TABLE IF NOT EXISTS [LastActiveRequests]
    ([Id] INTEGER, [RequestId] INTEGER, [LastOpen] BLOB, FOREIGN KEY([RequestId]) REFERENCES Requests([Id]), UNIQUE([Id]));

INSERT OR IGNORE
    INTO [Requests] ([Id], [Url], [UrlParams], [Header], [Body])
    VALUES (1,
        "eu-test.oppwa.com",
        "v1/checkouts?entityId=8a8294174b7ecb28014b9699220015ca&amount=1.00&currency=EUR&paymentType=DB",
        "Authorization: Bearer OGE4Mjk0MTc0YjdlY2IyODAxNGI5Njk5MjIwMDE1Y2N8c3k2S0pzVDg=",
        NULL);


INSERT OR IGNORE
    INTO [LastActiveRequests] ([Id], [RequestId], [LastOpen])
    VALUES (1, 1, 1);
