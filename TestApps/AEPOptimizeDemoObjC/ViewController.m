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
@import AEPOptimize;
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
    
    [AEPMobileOptimize onPropositionsUpdate:^(NSDictionary<AEPDecisionScope *,AEPOptimizeProposition *> *propositionsDict) {

        AEPOptimizeProposition* textProposition = propositionsDict[textDecisionScope];
        NSLog(@"Callback Logging %ld Text Offer(s)", [textProposition.offers count]);
        for(AEPOffer* offer in textProposition.offers) {
            NSLog(@"Callback Text Offer Content:%@", offer.content);
        }
        
        AEPOptimizeProposition* imageProposition = propositionsDict[imageDecisionScope];
        NSLog(@"Callback Logging %ld Image Offer(s)", [imageProposition.offers count]);
        for(AEPOffer* offer in imageProposition.offers) {
            NSLog(@"Callback Image Offer Content:%@", offer.content);
        }
        
        AEPOptimizeProposition* htmlProposition = propositionsDict[htmlDecisionScope];
        NSLog(@"Callback Logging %ld Html Offer(s)", [htmlProposition.offers count]);
        for(AEPOffer* offer in htmlProposition.offers) {
            NSLog(@"Callback Html Offer Content:%@", offer.content);
        }
        
        AEPOptimizeProposition* jsonProposition = propositionsDict[jsonDecisionScope];
        NSLog(@"Callback Logging %ld Json Offer(s)", [jsonProposition.offers count]);
        for(AEPOffer* offer in jsonProposition.offers) {
            NSLog(@"Callback Json Offer Content:%@", offer.content);
        }
        
        AEPOptimizeProposition* targetProposition = propositionsDict[targetDecisionScope];
        NSLog(@"Callback Logging %ld Target Offer(s)", [targetProposition.offers count]);
        for(AEPOffer* offer in targetProposition.offers) {
            NSLog(@"Callback Target Offer Content:%@", offer.content);
        }
    }];
}

- (IBAction)updatePropositions:(id)sender {
    
    textDecisionScope = [[AEPDecisionScope alloc]initWithName: self.textEncodedDecisionScope.text];
    imageDecisionScope = [[AEPDecisionScope alloc]initWithName: self.imageEncodedDecisionScope.text];
    htmlDecisionScope = [[AEPDecisionScope alloc]initWithName: self.htmlEncodedDecisionScope.text];
    jsonDecisionScope = [[AEPDecisionScope alloc]initWithName: self.jsonEncodedDecisionScope.text];
    targetDecisionScope = [[AEPDecisionScope alloc]initWithName: self.targetMbox.text];
    
    [AEPMobileOptimize updatePropositions:@[
        textDecisionScope,
        imageDecisionScope,
        htmlDecisionScope,
        jsonDecisionScope,
        targetDecisionScope
    ] withXdm:@{@"xdmKey": @"1234"} andData:@{@"dataKey": @"5678"}];
}

- (IBAction)getPropositions:(id)sender {
    
    textDecisionScope = [[AEPDecisionScope alloc]initWithName: self.textEncodedDecisionScope.text];
    imageDecisionScope = [[AEPDecisionScope alloc]initWithName: self.imageEncodedDecisionScope.text];
    htmlDecisionScope = [[AEPDecisionScope alloc]initWithName: self.htmlEncodedDecisionScope.text];
    jsonDecisionScope = [[AEPDecisionScope alloc]initWithName: self.jsonEncodedDecisionScope.text];
    targetDecisionScope = [[AEPDecisionScope alloc]initWithName: self.targetMbox.text];
    
    [AEPMobileOptimize getPropositions:@[
        textDecisionScope,
        imageDecisionScope,
        htmlDecisionScope,
        jsonDecisionScope,
        targetDecisionScope
    ] completion:^(NSDictionary<AEPDecisionScope *,AEPOptimizeProposition *>* propositionsDict, NSError* error) {
        if (error != nil) {
            NSLog(@"Get propositions failed with error: %@", [error localizedDescription]);
            return;
        }
        
        AEPOptimizeProposition* textProposition = propositionsDict[textDecisionScope];
        NSLog(@"Logging %ld Text Offer(s)", [textProposition.offers count]);
        for(AEPOffer* offer in textProposition.offers) {
            NSLog(@"Text Offer Content:%@", offer.content);
        }
        
        AEPOptimizeProposition* imageProposition = propositionsDict[imageDecisionScope];
        NSLog(@"Logging %ld Image Offer(s)", [imageProposition.offers count]);
        for(AEPOffer* offer in imageProposition.offers) {
            NSLog(@"Image Offer Content:%@", offer.content);
        }
        
        AEPOptimizeProposition* htmlProposition = propositionsDict[htmlDecisionScope];
        NSLog(@"Logging %ld Html Offer(s)", [htmlProposition.offers count]);
        for(AEPOffer* offer in htmlProposition.offers) {
            NSLog(@"Html Offer Content:%@", offer.content);
        }
        
        AEPOptimizeProposition* jsonProposition = propositionsDict[jsonDecisionScope];
        NSLog(@"Logging %ld Json Offer(s)", [jsonProposition.offers count]);
        for(AEPOffer* offer in jsonProposition.offers) {
            NSLog(@"Json Offer Content:%@", offer.content);
        }
        
        AEPOptimizeProposition* targetProposition = propositionsDict[targetDecisionScope];
        NSLog(@"Logging %ld Target Offer(s)", [targetProposition.offers count]);
        for(AEPOffer* offer in targetProposition.offers) {
            NSLog(@"Target Offer Content:%@", offer.content);
        }
    }];
}

- (IBAction)clearPropositions:(id)sender {
    [AEPMobileOptimize clearCachedPropositions];
}

- (IBAction)displayMultipleOffers:(id)sender {
    textDecisionScope = [[AEPDecisionScope alloc]initWithName: self.textEncodedDecisionScope.text];
    imageDecisionScope = [[AEPDecisionScope alloc]initWithName: self.imageEncodedDecisionScope.text];
    htmlDecisionScope = [[AEPDecisionScope alloc]initWithName: self.htmlEncodedDecisionScope.text];
    jsonDecisionScope = [[AEPDecisionScope alloc]initWithName: self.jsonEncodedDecisionScope.text];
    targetDecisionScope = [[AEPDecisionScope alloc]initWithName: self.targetMbox.text];
    
    [AEPMobileOptimize updatePropositions:@[
        textDecisionScope,
        imageDecisionScope,
        htmlDecisionScope,
        jsonDecisionScope,
        targetDecisionScope
    ] withXdm:@{@"xdmKey": @"1234"} andData:@{@"dataKey": @"5678"} completion:^(NSDictionary<AEPDecisionScope *,AEPOptimizeProposition *>* propositionsDict, NSError* error) {
        if (error != nil && [error.domain isEqualToString:@"com.adobe.AEPOptimize.AEPOptimizeError"]) {
            NSLog(@"Status: %@", error.userInfo[@"status"]);
            NSLog(@"Title: %@", error.userInfo[@"title"]);
            NSLog(@"Detail: %@", error.userInfo[@"detail"]);
            NSLog(@"Report: %@", error.userInfo[@"report"]);
            NSLog(@"AEPError: %@", error.userInfo[@"aepError"]);
            NSLog(@"Update propositions failed with error: %@", [error localizedDescription]);
            return;
        }
        
        // Collect all offers from all propositions
        NSMutableArray<AEPOffer *> *allOffers = [NSMutableArray array];
        
        for (AEPDecisionScope *scope in propositionsDict) {
            AEPOptimizeProposition *proposition = propositionsDict[scope];
            [allOffers addObjectsFromArray:proposition.offers];
        }
        
        if (allOffers.count > 0) {
            // Display all offers at once
            [AEPMobileOptimize displayed:allOffers];
            NSLog(@"Displayed %ld offers", (long)allOffers.count);
            
            NSDictionary *xdmData = [AEPMobileOptimize generateDisplayInteractionXdm:allOffers];
            NSLog(@"XDM Data: %@", xdmData);
            
        } else {
            NSLog(@"No offers available to display");
        }
    }];
}

@end
