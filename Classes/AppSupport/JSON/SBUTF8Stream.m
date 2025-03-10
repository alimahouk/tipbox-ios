/*
 Copyright (c) 2011, Stig Brautaset. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are
 met:
 
 Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 Neither the name of the the author nor the names of its contributors
 may be used to endorse or promote products derived from this software
 without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
 IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
 TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "SBUTF8Stream.h"


@implementation SBUTF8Stream

@synthesize index = _index;

- (id)init {
    self = [super init];
    if (self) {
        _data = [[NSMutableData alloc] initWithCapacity:4096u];
    }
    return self;
}

- (void)dealloc {
    [_data release];
    [super dealloc];
}

- (void)appendData:(NSData *)data_ {
    
    if (_index) {
        // Discard data we've already parsed
		[_data replaceBytesInRange:NSMakeRange(0, _index) withBytes:"" length:0];
        
        // Keep track of how much we have discarded
        _discarded += _index;
        
        // Reset index to point to current position
		_index = 0;
	}
    
    [_data appendData:data_];
    
    // This is an optimisation. 
    _bytes = [_data bytes];
    _length = [_data length];
}


- (BOOL)getUnichar:(unichar*)ch {
    if (_index < _length) {
        *ch = (unichar)_bytes[_index];
        return YES;
    }
    return NO;
}

- (BOOL)getNextUnichar:(unichar*)ch {
    if (++_index < _length) {
        *ch = (unichar)_bytes[_index];
        return YES;
    }
    return NO;
}

- (void)skip {
    _index++;
}

- (void)skipWhitespace {
    NSCharacterSet *ws = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    unichar ch;
    if (![self getUnichar:&ch])
        return;
    
    while ([ws characterIsMember:ch] && [self getNextUnichar:&ch])
        ;
}

- (BOOL)ensureChars:(NSUInteger)chars {
    return [_data length] - _index >= chars;
}

- (BOOL)skipCharacters:(const char *)chars length:(NSUInteger)len {
    const void *bytes = [_data bytes] + _index;
    if (!memcmp(bytes, chars, len)) {
        _index += len;
        return YES;
    }
    return NO;
}

- (BOOL)getBytes:(char *)bytes length:(NSUInteger)length {
    if (![self ensureChars:length])
        return NO;
    
    memcpy(bytes, _bytes + _index, length);
    bytes[length] = 0x0; // terminating NUL byte
    return YES;
}


@end
