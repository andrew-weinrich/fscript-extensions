"Class that provides and easy way to save and read files encrypted with a password-derived AES-128 key"
EncryptedStore := FSClass newClass:'EncryptedStore'.

EncryptedStore addClassProperty:'keySize' withValue:128.

EncryptedStore onClassMessage:#storeFromFile:withPassword: do:[ :self :fileName :password | |key|
    key := AESKey alloc initWithPassword:password keySize:(EncryptedStore keySize).
    EncryptedStore storeFromFile:fileName withKey:key.
].

EncryptedStore onClassMessage:#storeFromFile:withKey: do:[ :self :fileName :key |
    |archive encryptedStore encodedStore decodedStore computedHash encodedHash|
    
    "Read the encrypted store, check to see if there"
    encryptedStore := NSData dataWithContentsOfFile:fileName.
    
    (encryptedStore==nil) ifTrue:[
        (NSException exceptionWithName:'EncryptedStoreException' reason:'Could not read file '++fileName userInfo:nil)
            raise.
    ]
    ifFalse:[
        encodedStore := key decryptMessage:encryptedStore.
        NSKeyedUnarchiver unarchiveObjectWithData:encodedStore.
    ].
].

EncryptedStore onClassMessage:#saveStore:toFile:withPassword: do:[ :self :store :fileName :password | |key|
    key := AESKey alloc initWithPassword:password keySize:(EncryptedStore keySize).
    EncryptedStore saveStore:store toFile:fileName withKey:key.
].

EncryptedStore onClassMessage:#saveStore:toFile:withKey: do:[ :self :store :fileName :key |
    |encodedStore hash encryptedStore archive|
    
    "Encode the keystore dictionary"
    encodedStore := NSKeyedArchiver archivedDataWithRootObject:store.
    
    "Encrypt the store using the password as a key"
    encryptedStore := key encryptMessage:encodedStore.
    
    "Save the store to disk - returns true/false: whether or not the writing succeeded"
    encryptedStore writeToFile:fileName atomically:true.
].