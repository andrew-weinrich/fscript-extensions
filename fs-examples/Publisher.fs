sys import:'Dictionary'.
sys import:'EncryptedStore'.
sys import:'Subscriber'.


Publisher := FSClass newClass:'Publisher' 
                   properties:{'subscribers', 'publications', 'key', 'fileName', 'password'}.

Publisher addClassProperty:'messageKeyLength' withValue:128.
Publisher addClassProperty:'messageIdLength' withValue:64.
Publisher addClassProperty:'bucketListSize' withValue:11.


Publisher onClassMessage:#publisherWithPassword:fileName: do:[ :self :password :fileName | |publisher|
    publisher := self alloc init.
    publisher setFileName:fileName.
    publisher setPassword:password.
    
    "Initialize from a saved store if one is available"
    (NSFileManager defaultManager test_f:fileName) ifTrue:[ |archive|
        archive := EncryptedStore storeFromFile:fileName withPassword:password.
        (archive==nil) ifFalse:[
            out println:('Initializing from archive').
            
            publisher setSubscribers:(archive objectForKey:'subscribers').
            publisher setPublications:(archive objectForKey:'publications').
            publisher setKey:(archive objectForKey:'key').
            publisher.
        ]
        ifTrue:[
            nil.
        ]
    ]
    ifFalse:[ |newKey|
        publisher setSubscribers:(NSMutableDictionary dictionary).
        publisher setPublications:(NSMutableDictionary dictionary).
        newKey := RSAKeyPair alloc initWithNewKeyOfDefaultSize.
        publisher setKey:newKey.
        publisher.
    ]
].



"Returns a message in XML format"
Publisher onMessage:#publishContent:forPublication: do:[ :self :content :publicationName |
    |xmlDoc root messageId messageKey encryptedData encryptedMessage|
    
    "Create Create root document"
    root := NSXMLNode elementWithName:'event'.
    
    "Create message key, encrypted event data, and signature"
    messageKey := AESKey alloc initWithNewKeyOfSize:(Publisher messageKeyLength).
    out println:'Message key: ' ++ messageKey keyData description.

    "Unique message id"
    messageId := NSData alloc initWithRandomDataOfLength:(Publisher messageIdLength / 8).
    
    "Create header"
    [ |headerNode|
        headerNode := NSXMLNode elementWithName:'header'.
    
        "Create and add node for the message id"
        [ |messageIdNode|
            messageIdNode := NSXMLNode elementWithName:'messageId'.
            messageIdNode setObjectValue:messageId.
            out println:'Message id: ' ++ messageId description.
            headerNode addChild:messageIdNode.
        ] value.
    
    
        "Create and add the signature"
        "Signature is for the messageid and message put together"
        [ |signatureData signature signatureNode|
            signatureData := NSMutableData alloc init.
            signatureData appendData:messageId.
            signatureData appendData:content.
            signature := (self key) signMessage:signatureData.
            signatureNode := NSXMLNode elementWithName:'signature'.
            signatureNode setObjectValue:signature.
            headerNode addChild:signatureNode.
        ] value.
        
        [ |rawBucketData bucketList|
            "Create the raw bucket entry data, which will be encrypted by each user's public key"
            rawBucketData := NSMutableData alloc init.
            rawBucketData appendData:messageId.
            rawBucketData appendData:(messageKey keyData).

            "Create key hash table"
            bucketList := NSXMLNode elementWithName:'keylist'.
            1 to:(Publisher bucketListSize) do:[ :i | |bucket|
                bucket := NSXMLNode elementWithName:'keybucket'.
                bucketList addChild:bucket.
            ].

            "Encode and add the hash keys for every subscriber to this message"
            allSubscribers := self subscribers allValues.
            eventSubscribers := allSubscribers at:(allSubscribers isSubscribedToFeed:publicationName).
            [ :subscriber | |tableLocation keyEntry index|
                index := subscriber key low32BitsOfPublicKeyAsUnsignedInteger.
                tableLocation := index % Publisher bucketListSize.
                keyEntry := NSXMLNode elementWithName:'keyentry'.
                keyEntry setObjectValue:(subscriber key encryptMessage:rawBucketData).

                out println:('Adding entry for subscriber ' ++ subscriber name ++ 
                    ' (index '++index description++') at bucket ' ++ tableLocation description).
                (bucketList childAtIndex:tableLocation) addChild:keyEntry.
            ]
            value:@eventSubscribers.
            
            "Go back through all buckets and add dummy data"
            1 to:(Publisher bucketListSize) do:[ :i | |bucket|
                bucket := bucketList childAtIndex:(i-1).
                
                1 to:(3 random + 1) do:[ :i | |dummyEntry|
                    dummyEntry := NSXMLNode elementWithName:'keyentry'.
                    dummyEntry setObjectValue:(NSData alloc initWithRandomDataOfLength:129).
                    bucket addChild:dummyEntry.
                ].
            ].
            
            headerNode addChild:bucketList.
        ] value.
        
        root addChild:headerNode.
    ] value.
    
    
    "Create and add the body"
    [ |body|
        body := NSXMLNode elementWithName:'eventdata'.
        body setObjectValue:(messageKey encryptMessage:content).
        root addChild:body.
    ] value.
    
    "Create and return an XML document"
    xmlDoc := NSXMLDocument alloc initWithRootElement:root.
    xmlDoc setVersion:'1.0'.
    xmlDoc setCharacterEncoding:'UTF-8'.
    xmlDoc.    
].
    




"private methods"
Publisher onMessage:#saveToDisk do:[ :self | |archive|
    archive := NSDictionary dictionaryFromPairs:{
        'subscribers' => self subscribers,
        'key' => self key,
        'publications' => self publications
    }.
    
    EncryptedStore saveStore:archive toFile:(self fileName) withPassword:(self password).
].




