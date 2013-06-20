
source shunit_assert.sh

# Catalogue of tests
# T1 main project with a buildNumber
#    clean, build, archive, deploy current build, install current build
# T2 main and sub projects with a buildNumber
#    clean, build, archive, deploy current build, install current build
# T3 main and sub projects no buildNumber
#    clean, build snapshot, archive fails as snapshot, deploy fails as snapshot, install fails as snapshot
# T4 deploy install named projects with a buildNumber
#    deploy project, install project, cannot install snapshot, deploy does not exist, install does not exist (OK), install fails
# T5 deploy named projects with a deployVersion
#    deploy project, deploy does not exist, deploy with installVersion fails
# T6 install named projects with an installVersion
#    install project, install does not exist (OK), install fails, install with deploy version fails

function before() {
  rm -rf ~/deploy_local ~/archive_local/*
}

function T1() {
	before
	gradle -P destination=local -P buildNumber=1 clean
	assertStat $? "T1 clean"
	assertNotExists build
	
	gradle -P destination=local -P buildNumber=1 build
	assertStat $? "T1 build"
	assertFileExists build/distributions/testenv-1.0.1.tgz "T1 build"
	
	gradle -P destination=local -P buildNumber=1 archive
	assertStat $? "T1 archive"
	assertFileExists ~/archive_local/testenv-1.0.1.tgz "T1 archive"
	
	gradle -P destination=local -P buildNumber=1 deploy
	assertStat $? "T1 deploy"
	assertDirExists ~/deploy_local/testenv-1.0.1 "T1 deploy"
	
	gradle -P destination=local -P buildNumber=1 install
	assertStat $? "T1 install"

  gradle -P destination=local -P buildNumber=1 rollback
  assertStat $? "T1 rollback"
}

function T2() {
	before
	
	gradle --settings-file settings.gradle.sub -P destination=local -P buildNumber=1 clean
	assertStat $? "T2 clean"
	assertNotExists build
	
	gradle --settings-file settings.gradle.sub -P destination=local -P buildNumber=1 build
	assertStat $? "T2 build"
	assertFileExists build/distributions/testenv_root-1.0.1.tgz "T2 build testenv_root"
	assertFileExists sub1/build/distributions/sub1-1.0.1.tgz "T2 build sub1"
	assertFileExists sub2/build/distributions/sub2-1.0.1.tgz "T2 build sub2"
	
	gradle --settings-file settings.gradle.sub -P destination=local -P buildNumber=1 archive
	assertStat $? "T2 archive"
	assertFileExists ~/archive_local/testenv_root-1.0.1.tgz "T2 archive testenv_root"
	assertFileExists ~/archive_local/sub1-1.0.1.tgz "T2 archive sub1"
	assertFileExists ~/archive_local/sub2-1.0.1.tgz "T2 archive sub2"
	
	gradle --settings-file settings.gradle.sub -P destination=local -P buildNumber=1 deploy
	assertStat $? "T2 deploy"
	assertDirExists ~/deploy_local/testenv_root-1.0.1 "T2 deploy testenv_root"
	assertDirExists ~/deploy_local/sub1-1.0.1 "T2 deploy sub1"
	assertDirExists ~/deploy_local/sub2-1.0.1 "T2 deploy sub2"
	
#gradle --settings-file settings.gradle.sub -P destination=local -P buildNumber=1 install
#assertStat $? "T2 install"
}

function T3() {
	before
	
	gradle --settings-file settings.gradle.sub -P destination=local clean
	assertStat $? "T3 clean"
	assertNotExists build
	
	gradle --settings-file settings.gradle.sub -P destination=local build
	assertStat $? "T3 build"
	assertFileExists build/distributions/testenv_root-1.0.SNAPSHOT.tgz "T3 build testenv_root"
	assertFileExists sub1/build/distributions/sub1-1.0.SNAPSHOT.tgz "T3 build sub1"
	assertFileExists sub2/build/distributions/sub2-1.0.SNAPSHOT.tgz "T3 build sub2"
	
	gradle --settings-file settings.gradle.sub -P destination=local archive
	assertStatFailed $? "T3 archive"
	assertNotExists ~/archive_local/testenv_root-1.0.SNAPSHOT.tgz "T3 archive testenv_root"
	assertNotExists ~/archive_local/sub1-1.0.SNAPSHOT.tgz "T3 archive sub1"
	assertNotExists ~/archive_local/sub2-1.0.SNAPSHOT.tgz "T3 archive sub2"
	
	gradle --settings-file settings.gradle.sub -P destination=local -P buildNumber=1 deploy
	assertStatFailed $? "T3 deploy"
	assertNotExists ~/deploy_local/testenv_root-1.0.SNAPSHOT "T3 deploy testenv_root"
	assertNotExists ~/deploy_local/sub1-1.0.SNAPSHOT "T3 deploy sub1"
	assertNotExists ~/deploy_local/sub2-1.0.SNAPSHOT "T3 deploy sub2"
}

function T4() {
	before
	
	gradle --settings-file settings.gradle.sub.fail -P destination=local -P buildNumber=1 clean build archive
	assertStat $? "T4 build"
	
	gradle -P destination=local -P buildNumber=1 -P archiveRoot=testenv_root deploy
	assertStat $? "T4 deploy testenv_root"
	assertDirExists ~/deploy_local/testenv_root-1.0.1 "deploy testenv_root"
	assertExists ~/deploy_local/testenv_root "dir testenv_root"
	
	gradle -P destination=local -P buildNumber=1 -P archiveRoot=testenv_root install
	assertStat $? "T4 install testenv_root"
	
  gradle -P destination=local -P buildNumber=1 -P archiveRoot=testenv_root rollback
  assertStat $? "T4 rollback testenv_root"
  
  gradle -P destination=local -P archiveRoot=testenv_root deloy
  assertStatFailed $? "T4 cannot deploy snapshot"
  
  gradle -P destination=local -P buildNumber=2 -P archiveRoot=testenv_root deploy
  assertStatFailed $? "T4 deploy does not exist"
  
  gradle -P destination=local -P buildNumber=1 -P archiveRoot=sub1 deploy install
	assertStat $? "T4 install not exist (OK)"
	assertDirExists ~/deploy_local/sub1-1.0.1 "T4 deploy sub1"
	assertExists ~/deploy_local/sub1 "T4 dir sub1"

	gradle -P destination=local -P buildNumber=1 -P archiveRoot=sub1 rollback
  assertStat $? "T4 rollback not exist (OK)"
			
	gradle -P destination=local -P buildNumber=1 -P archiveRoot=subfail deploy install
	assertStatFailed $? "T4 install fails"
	assertDirExists ~/deploy_local/subfail-1.0.1 "T4 deploy subfail"
	assertExists ~/deploy_local/subfail "T4 dir subfail"
	assertExists ~/deploy_local/subfail/install/install-1.0.sh  "T4 install exists subfail"

  gradle -P destination=local -P buildNumber=1 -P archiveRoot=subfail rollback
  assertStatFailed $? "T4 rollback fails"
}

function T5() {  
  before
  gradle --settings-file settings.gradle.sub -P destination=local -P buildNumber=1 clean build archive
  assertStat $? "T5 build"
  
  gradle -P destination=local -P deployVersion=1.0.1 -P archiveRoot=sub1 deploy
  assertStat $? "T5 deploy sub1"
  assertDirExists ~/deploy_local/sub1-1.0.1 "deploy sub1"
  assertExists ~/deploy_local/sub1 "dir sub1"

  gradle -P destination=local -P deployVersion=1.1.1 -P archiveRoot=sub1 deploy
  assertStatFailed $? "T5 deploy fails"

  gradle -P destination=local -P installVersion=1.0 -P archiveRoot=sub1 deploy
  assertStatFailed $? "T5 deploy fails without deployVersion and installVersion instead"
}

function T6() {
  before
  gradle --settings-file settings.gradle.sub.fail -P destination=local -P buildNumber=1 clean build archive
  assertStat $? "T6 build"

  gradle -P destination=local -P deployVersion=1.0.1 -P archiveRoot=subfail deploy
  assertStat $? "T6 deploy subfail"

  gradle -P destination=local -P deployVersion=1.0.1 -P archiveRoot=sub1 deploy
  assertStat $? "T6 deploy sub1"

  gradle -P destination=local -P installVersion=1.0 -P archiveRoot=sub1 install
  assertStat $? "T6 nothing to install sub1"

  gradle -P destination=local -P installVersion=1.0 -P archiveRoot=sub1 rollback
  assertStat $? "T6 nothing to rollback sub1"

  gradle -P destination=local -P installVersion=1.0 -P archiveRoot=testenv_root install
  assertStat $? "T6 install testenv_root"

  gradle -P destination=local -P installVersion=1.0 -P archiveRoot=testenv_root rollback
  assertStat $? "T6 rollback testenv_root"

  gradle -P destination=local -P installVersion=1.0 -P archiveRoot=subfail install
  assertStatFailed $? "T6 install subfail"

  gradle -P destination=local -P installVersion=1.0 -P archiveRoot=subfail rollback
  assertStatFailed $? "T6 rollback subfail"

  gradle -P destination=local -P installVersion=1.1 -P archiveRoot=sub1 install
  assertStat $? "T6 install sub1 1.1 does not exist (ok)"

  gradle -P destination=local -P deployVersion=1.0.1 -P archiveRoot=sub1 -P major=2 install
  assertStat $? "T6 install sub1 no installVersion"
}

{ # braces for logging

T1
T2
T3
T4
T5
T6

} 2>&1 | tee $0.log 

bell


