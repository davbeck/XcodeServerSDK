//
//  SourceControlBlueprint.swift
//  Buildasaur
//
//  Created by Honza Dvorsky on 11/01/2015.
//  Copyright (c) 2015 Honza Dvorsky. All rights reserved.
//

import Foundation
import BuildaUtils

extension String {
    public var base64Encoded: String? {
		let data = self.data(using: String.Encoding.utf8, allowLossyConversion: false)
		return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}

public class SourceControlBlueprint : XcodeServerEntity {
    
    public let branch: String
    public let projectWCCIdentifier: String
    public let wCCName: String
    public let projectName: String
    public let projectURL: String
    public let projectPath: String
    public let commitSHA: String?
    public let privateSSHKey: String?
    public let publicSSHKey: String?
    public let sshPassphrase: String?
    public var certificateFingerprint: String? = nil
    
    public required init(json: [String:Any]) throws {
		self.wCCName = try json[XcodeBlueprintNameKey].unwrap(as: String.self)

        let primaryRepoId = try json[XcodeBlueprintPrimaryRemoteRepositoryKey].unwrap(as: String.self)
        self.projectWCCIdentifier = primaryRepoId

        let workingCopyPaths = try json[XcodeBlueprintWorkingCopyPathsKey].unwrap(as: [String:Any].self)
        self.projectName = try workingCopyPaths[primaryRepoId].unwrap(as: String.self)

        let repos = try json[XcodeBlueprintRemoteRepositoriesKey].unwrap(as: [[String:Any]].self)
        let primarys: [[String:Any]] = try repos.filter {
            (item: [String:Any]) -> Bool in
            return try item[XcodeBlueprintRemoteRepositoryIdentifierKey].unwrap(as: String.self) == primaryRepoId
        }
        
        self.projectPath = try json[XcodeBlueprintRelativePathToProjectKey].unwrap(as: String.self)

        let repo = primarys.first!
        self.projectURL = try repo[XcodeBlueprintRemoteRepositoryURLKey].unwrap(as: String.self)
        self.certificateFingerprint = repo[XcodeBlueprintRemoteRepositoryCertFingerprintKey] as? String
        
        let locations = try json[XcodeBlueprintLocationsKey].unwrap(as: [String:Any].self)
        let location = try locations[primaryRepoId].unwrap(as: [String:Any].self)
        self.branch = location[XcodeBranchIdentifierKey] as? String ?? ""
        self.commitSHA = location[XcodeLocationRevisionKey] as? String
        
        let authenticationStrategy = (json[XcodeRepositoryAuthenticationStrategiesKey] as? [String:Any])?[primaryRepoId] as? [String:Any]
        
        self.privateSSHKey = authenticationStrategy?[XcodeRepoAuthenticationStrategiesKey] as? String
        self.publicSSHKey = authenticationStrategy?[XcodeRepoPublicKeyDataKey] as? String
        self.sshPassphrase = authenticationStrategy?[XcodeRepoPasswordKey] as? String
        
        try super.init(json: json)
    }
    
    public init(branch: String, projectWCCIdentifier: String, wCCName: String, projectName: String,
        projectURL: String, projectPath: String, publicSSHKey: String?, privateSSHKey: String?, sshPassphrase: String?, certificateFingerprint: String? = nil)
    {
        self.branch = branch
        self.projectWCCIdentifier = projectWCCIdentifier
        self.wCCName = wCCName
        self.projectName = projectName
        self.projectURL = projectURL
        self.projectPath = projectPath
        self.commitSHA = nil
        self.publicSSHKey = publicSSHKey
        self.privateSSHKey = privateSSHKey
        self.sshPassphrase = sshPassphrase
        self.certificateFingerprint = certificateFingerprint
        
        super.init()
    }
    
    //for credentials verification only
    public convenience init(projectURL: String, publicSSHKey: String?, privateSSHKey: String?, sshPassphrase: String?) {
        
        self.init(branch: "", projectWCCIdentifier: "", wCCName: "", projectName: "", projectURL: projectURL, projectPath: "", publicSSHKey: publicSSHKey, privateSSHKey: privateSSHKey, sshPassphrase: sshPassphrase)
    }
    
    public func dictionarifyRemoteAndCredentials() -> [String:Any] {
        
        var dictionary = [String:Any]()

        let repoId = self.projectWCCIdentifier
        let remoteUrl = self.projectURL
        let sshPublicKey = self.publicSSHKey?.base64Encoded ?? ""
        let sshPrivateKey = self.privateSSHKey?.base64Encoded ?? ""
        let sshPassphrase = self.sshPassphrase ?? ""
        let certificateFingerprint = self.certificateFingerprint ?? ""

        //blueprint is not valid without this magic version
        dictionary[XcodeBlueprintVersion] = 203
        
        //now, a repo is defined by its server location. so let's throw that in.
        dictionary[XcodeBlueprintRemoteRepositoriesKey] = [
            [
                XcodeBlueprintRemoteRepositoryURLKey: remoteUrl,
                XcodeBlueprintRemoteRepositorySystemKey: "com.apple.dt.Xcode.sourcecontrol.Git", //TODO: add more SCMs
                XcodeBlueprintRemoteRepositoryIdentifierKey: repoId,
                
                //new - certificate fingerprint
                XcodeBlueprintRemoteRepositoryCertFingerprintKey: certificateFingerprint,
                XcodeBlueprintRemoteRepositoryTrustSelfSignedCertKey: true
            ]
        ]
        
        //but since there might be multiple repos (think git submodules), we need to declare
        //the primary one.
        dictionary[XcodeBlueprintPrimaryRemoteRepositoryKey] = repoId
        
        //now, this is enough for a valid blueprint. it might not be too useful, but it's valid.
        //to make our supported (git) repos work, we also need some credentials.
        
        //repo authentication
        //again, since we can provide information for multiple repos, keep the repo's id close.
        dictionary[XcodeRepositoryAuthenticationStrategiesKey] = [
            repoId: [
                XcodeRepoAuthenticationTypeKey: XcodeRepoSSHKeysAuthenticationStrategy,
                XcodeRepoUsernameKey: "git", //TODO: see how to add https support?
                XcodeRepoPasswordKey: sshPassphrase,
                XcodeRepoAuthenticationStrategiesKey: sshPrivateKey,
                XcodeRepoPublicKeyDataKey: sshPublicKey
            ]
        ]
        
        //up to this is all we need to verify credentials and fingerprint during preflight
        //which is now under /api/scm/branches. all the stuff below is useful for actually *creating*
        //a bot.
        
        return dictionary
    }
    
	private func dictionarifyForBotCreation() -> [String:Any] {
        var dictionary = self.dictionarifyRemoteAndCredentials()

        let repoId = self.projectWCCIdentifier
        var workingCopyPath = self.projectName
        //ensure a trailing slash
        if !workingCopyPath.hasSuffix("/") {
            workingCopyPath = workingCopyPath + "/"
        }
        let relativePathToProject = self.projectPath
        let blueprintName = self.wCCName
        let branch = self.branch
        
        //we're creating a bot now.
        
        //our bot has to know which code to check out - we declare that by giving it a branch to track.
        //in our case it can be "master", for instance.
        dictionary[XcodeBlueprintLocationsKey] = [
            repoId: [
                XcodeBranchIdentifierKey: branch,
                XcodeBranchOptionsKey: 156, //super magic number
                XcodeBlueprintLocationTypeKey: "DVTSourceControlBranch" //TODO: add more types?
            ]
        ]
        
        //once XCS checks out your repo, it also needs to know how to get to your working copy, in case
        //you have a complicated multiple-folder repo setup. coming from the repo's root, for us it's
        //something like "XcodeServerSDK/"
        dictionary[XcodeBlueprintWorkingCopyPathsKey] = [
            repoId: workingCopyPath
        ]
        
        //once we're in our working copy, we need to know which Xcode project/workspace to use!
        //this is relative to the working copy above. all coming together, huh? here
        //it would be "XcodeServerSDK.xcworkspace"
        dictionary[XcodeBlueprintRelativePathToProjectKey] = relativePathToProject
        
        //now we've given it all we knew. what else?
        
        //turns out there are a couple more keys that XCS needs to be happy. so let's feed the beast.
        
        //every nice data structure needs a name. so give the blueprint one as well. this is usually
        //the same as the name of your project, "XcodeServerSDK" in our case here
        dictionary[XcodeBlueprintNameKey] = blueprintName
        
        //just feed the beast, ok? this has probably something to do with working copy state, git magic.
        //we pass 0. don't ask.
        dictionary[XcodeBlueprintWorkingCopyStatesKey] = [
            repoId: 0
        ]
        
        //and to uniquely identify this beauty, we also need to give it a UUID. well, technically I think
        //Xcode generates a hash from the data somehow, but passing in a random UUID works as well, so what the hell.
        //if someone figures out how to generate the same ID as Xcode does, I'm all yours.
        //TODO: give this a good investigation.
        dictionary[XcodeBlueprintIdentifierKey] = UUID().uuidString
        
        //and this is the end of our journey to create a new Blueprint. I hope you enjoyed the ride, please return the 3D glasses to the green bucket on your way out.
        
        return dictionary
    }
    
    public override func dictionarify() -> [String:Any] {
        return self.dictionarifyForBotCreation()
    }
}

