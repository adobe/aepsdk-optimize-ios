/*
Copyright 2021 Adobe. All rights reserved.
This file is licensed to you under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License. You may obtain a copy
of the License at http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under
the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR REPRESENTATIONS
OF ANY KIND, either express or implied. See the License for the specific language
governing permissions and limitations under the License.
*/
    

#import "ViewController.h"
@import AEPEdgePersonalization;
@import AEPServices;

@interface ViewController ()

@end

@implementation ViewController

AEPDecisionScope *textDecisionScope;
AEPDecisionScope* imageDecisionScope;
AEPDecisionScope* htmlDecisionScope;
AEPDecisionScope* jsonDecisionScope;
AEPDecisionScope* targetDecisionScope;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [AEPMobileEdgePersonalization onPropositionsUpdate:^(NSDictionary<AEPDecisionScope *,AEPProposition *> *propositionsDict) {

        AEPProposition* textProposition = propositionsDict[textDecisionScope];
        NSLog(@"Callback Logging %ld Text Offer(s)", [textProposition.offers count]);
        for(AEPOffer* offer in textProposition.offers) {
            NSLog(@"Callback Text Offer Content:%@", offer.content);
        }
        
        AEPProposition* imageProposition = propositionsDict[imageDecisionScope];
        NSLog(@"Callback Logging %ld Image Offer(s)", [imageProposition.offers count]);
        for(AEPOffer* offer in imageProposition.offers) {
            NSLog(@"Callback Image Offer Content:%@", offer.content);
        }
        
        AEPProposition* htmlProposition = propositionsDict[htmlDecisionScope];
        NSLog(@"Callback Logging %ld Html Offer(s)", [htmlProposition.offers count]);
        for(AEPOffer* offer in htmlProposition.offers) {
            NSLog(@"Callback Html Offer Content:%@", offer.content);
        }
        
        AEPProposition* jsonProposition = propositionsDict[jsonDecisionScope];
        NSLog(@"Callback Logging %ld Json Offer(s)", [jsonProposition.offers count]);
        for(AEPOffer* offer in jsonProposition.offers) {
            NSLog(@"Callback Json Offer Content:%@", offer.content);
        }
        
        AEPProposition* targetProposition = propositionsDict[targetDecisionScope];
        NSLog(@"Callback Logging %ld Target Offer(s)", [targetProposition.offers count]);
        for(AEPOffer* offer in targetProposition.offers) {
            NSLog(@"Callback Target Offer Content:%@", offer.content);
        }
    }];
}

- (IBAction)updatePropositions:(id)sender {
    AEPExperienceData* experienceEventData = [[AEPExperienceData alloc]initWithXdm:@{@"xdmKey": @"1234"} data:@{@"dataKey": @"5678"} datasetIdentifier:@"1234-5678"];
    
    textDecisionScope = [[AEPDecisionScope alloc]initWithName: self.textEncodedDecisionScope.text];
    imageDecisionScope = [[AEPDecisionScope alloc]initWithName: self.imageEncodedDecisionScope.text];
    htmlDecisionScope = [[AEPDecisionScope alloc]initWithName: self.htmlEncodedDecisionScope.text];
    jsonDecisionScope = [[AEPDecisionScope alloc]initWithName: self.jsonEncodedDecisionScope.text];
    targetDecisionScope = [[AEPDecisionScope alloc]initWithName: self.targetMbox.text];
    
    [AEPMobileEdgePersonalization updatePropositions:@[
        textDecisionScope,
        imageDecisionScope,
        htmlDecisionScope,
        jsonDecisionScope,
        targetDecisionScope
    ] withExperienceData:experienceEventData];
}

- (IBAction)getPropositions:(id)sender {
    
    textDecisionScope = [[AEPDecisionScope alloc]initWithName: self.textEncodedDecisionScope.text];
    imageDecisionScope = [[AEPDecisionScope alloc]initWithName: self.imageEncodedDecisionScope.text];
    htmlDecisionScope = [[AEPDecisionScope alloc]initWithName: self.htmlEncodedDecisionScope.text];
    jsonDecisionScope = [[AEPDecisionScope alloc]initWithName: self.jsonEncodedDecisionScope.text];
    targetDecisionScope = [[AEPDecisionScope alloc]initWithName: self.targetMbox.text];
    
    [AEPMobileEdgePersonalization getPropositions:@[
        textDecisionScope,
        imageDecisionScope,
        htmlDecisionScope,
        jsonDecisionScope,
        targetDecisionScope
    ] completion:^(NSDictionary<AEPDecisionScope *,AEPProposition *>* propositionsDict, NSError* error) {
        if (error != nil) {
            NSLog(@"Get propositions failed with error: %@", [error localizedDescription]);
            return;
        }
        
        AEPProposition* textProposition = propositionsDict[textDecisionScope];
        NSLog(@"Logging %ld Text Offer(s)", [textProposition.offers count]);
        for(AEPOffer* offer in textProposition.offers) {
            NSLog(@"Text Offer Content:%@", offer.content);
        }
        
        AEPProposition* imageProposition = propositionsDict[imageDecisionScope];
        NSLog(@"Logging %ld Image Offer(s)", [imageProposition.offers count]);
        for(AEPOffer* offer in imageProposition.offers) {
            NSLog(@"Image Offer Content:%@", offer.content);
        }
        
        AEPProposition* htmlProposition = propositionsDict[htmlDecisionScope];
        NSLog(@"Logging %ld Html Offer(s)", [htmlProposition.offers count]);
        for(AEPOffer* offer in htmlProposition.offers) {
            NSLog(@"Html Offer Content:%@", offer.content);
        }
        
        AEPProposition* jsonProposition = propositionsDict[jsonDecisionScope];
        NSLog(@"Logging %ld Json Offer(s)", [jsonProposition.offers count]);
        for(AEPOffer* offer in jsonProposition.offers) {
            NSLog(@"Json Offer Content:%@", offer.content);
        }
        
        AEPProposition* targetProposition = propositionsDict[targetDecisionScope];
        NSLog(@"Logging %ld Target Offer(s)", [targetProposition.offers count]);
        for(AEPOffer* offer in targetProposition.offers) {
            NSLog(@"Target Offer Content:%@", offer.content);
        }
    }];
}

- (IBAction)clearPropositions:(id)sender {
    [AEPMobileEdgePersonalization clearCachedPropositions];
}

@end
