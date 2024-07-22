#! /bin/bash

## META DATA
## =========

export title="Hartnett Pubic Age Estimation"
export shortname="hpa"
export version="0.0.1"
export date="2024-07-22"
export ontology_iri="http://w3id.org/rdfbones/ext/hpa/latest/hpa.owl"
export version_iri="http://w3id.org/rdfbones/ext/hpa/v0-0-1/hpa.owl"
export creators="Felix Engel"
export contributors=("Stefan Schlager" "Lukas Bender")
export description="This RDFBones ontology extension implements the pubic age estimation technique published in Hartnett (2010)."
export comment="This RDFBones ontology extension implements the pubic age estimation technique published in Hartnett (2010)."
export source="Hartnett, K. M. (2010). Analysis of Age-at-Death Estimation Using Data from a New, Modern Autopsy Sample—Part I: Pubic Bone. Journal of Forensic Sciences 55(5). doi: 10.1111/j.1556-4029.2010.01399.x"


## VARIABLES
## =========

export cleanup=0
export update=0
export build=0
export full=0
export verbose=0


## USAGE FUNCTION
## ==============

function usage {
    echo " "
    echo "usage: $0 [-b][-c][-u]"
    echo " "
    echo "    -b          build owl file"
    echo "    -c          cleanup temporary files"
    echo "    -u          initialise/update submodules"
    echo "    -f          merge extension with the core ontology and all dependencies and output as one owl file"
    echo "    -v          verbose mode"
    echo "    -h -?       print this help"

    exit

}

while getopts "bcufvh?" opt; do
    case "$opt" in
	c)
	    cleanup=1
	    ;;
	u)
	    update=1
	    ;;
	b)
	    build=1
	    ;;
	f)
	    full=1
	    ;;
	v)
	    verbose=1
	    ;;
	?)
	    usage
	    ;;
	h)
	    usage
	    ;;
    esac
done

if [ -z "$1" ]; then
    usage
fi


## SUBMODULES
## ==========

## Check if submodules are initialised

gitchk=$(git submodule foreach 'echo $sm_path `git rev-parse HEAD`')
if [ -z "$gitchk" ]; then
    
    update=1
    
fi

## Initialise and update git submodules

if [ $update -eq 1 ]; then

    if [ $verbose -eq 1 ]; then
	echo "Initialising git submodules"
    fi
    
    git submodule init

    if [ $verbose -eq 1 ]; then
	echo "Updating git submodules"
    fi
    
    git submodule update
fi


## BUILD ONTOLOGY EXTENSION
## ========================

if [ $build -eq 1 ]; then


    ## DEPENDENCIES
    ## ------------

    if [ $verbose -eq 1 ]; then

	echo "Building dependencies"

    fi

    ## Build core ontology

    cd dependencies/RDFBones-O/robot/

    ./Script-Build_RDFBones-Robot.sh

    cd ../../../
    
    ## Build Suchey Brooks pubic age estimation submodule
    
    cd dependencies/SucheyBrooksPubicAge/
    
    ./Script-Build_OntologyExtension-Robot.sh -b -c -u
    
    cd ../../

    ## Add additional build instructions as exemplified for the core ontology above
    ## ****************************************************************************

    ## Merge dependencies

    if [ $verbose -eq 1 ]; then

	echo "Merging dependencies"

    fi

    robot merge --input dependencies/RDFBones-O/robot/results/rdfbones.owl \
	  --input dependencies/SucheyBrooksPubicAge/results/sb.owl \
	  --output results/dependencies.owl
    
    ## Add additional dependencies files as input
    ## ******************************************


    ## TEMPLATES
    ## ---------

    if [ $verbose -eq 1 ]; then

	echo "Processing category labels template"

    fi
    
    ## Create category labels

    robot template --template template-category_labels.tsv \
	  --prefixes prefixes.json \
	  --input results/dependencies.owl \
	  --output results/template_CategoryLabels.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging category labels"

    fi
    
    robot merge --input results/dependencies.owl \
	  --input results/template_CategoryLabels.owl \
	  --output results/merged.owl


    ## Create value specifications

    if [ $verbose -eq 1 ]; then

	echo "Processing value specifications template"

    fi
    
    robot template --template template-value_specifications.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_ValueSpecifications.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging value specifications"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_ValueSpecifications.owl \
	  --output results/merged.owl

    robot merge --input results/template_CategoryLabels.owl \
	  --input results/template_ValueSpecifications.owl \
	  --output results/extension.owl


    ## Create data items

    if [ $verbose -eq 1 ]; then

	echo "Processing data items template"

    fi
    
    robot template --template template-data_items.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_DataItems.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging data items"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_DataItems.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_DataItems.owl \
	  --output results/extension.owl
    

    ## Create data sets

    if [ $verbose -eq 1 ]; then

	echo "Processing data sets template"

    fi

    robot template --template template-data_sets.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_DataSets.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging data sets"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_DataSets.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_DataSets.owl \
	  --output results/extension.owl

    
    ## Create assays

    if [ $verbose -eq 1 ]; then

	echo "Processing assays template"

    fi

    robot template --template template-assays.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_Assays.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging assays"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_Assays.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_Assays.owl \
	  --output results/extension.owl


    ## Create data transformations

    if [ $verbose -eq 1 ]; then

	echo "Processing data transformations template"

    fi
    
    robot template --template template-data_transformations.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_DataTransformations.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging data transformations"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_DataTransformations.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_DataTransformations.owl \
	  --output results/extension.owl


    ## Create Conclusion Processes

    if [ $verbose -eq 1 ]; then

	echo "Processing conclusion processes template"

    fi
    
    robot template --template template-conclusion_processes.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_ConclusionProcesses.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging conclusion processes"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_ConclusionProcesses.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_ConclusionProcesses.owl \
	  --output results/extension.owl


    ## Create Study Design Execution Processes

    if [ $verbose -eq 1 ]; then

	echo "Processing study design execution processes template"

    fi
    
    robot template --template template-study_design_executions.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_StudyDesignExecutions.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging study design execution processes"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_StudyDesignExecutions.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_StudyDesignExecutions.owl \
	  --output results/extension.owl


    ## Create Protocols

    if [ $verbose -eq 1 ]; then

	echo "Processing protocols template"

    fi
    
    robot template --template template-protocols.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_Protocols.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging protocols"

    fi

    robot merge --input results/merged.owl \
	  --input results/template_Protocols.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_Protocols.owl \
	  --output results/extension.owl


    ## Create Study Designs

    if [ $verbose -eq 1 ]; then

	echo "Processing study designs template"

    fi
    
    robot template --template template-study_designs.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_StudyDesigns.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging study designs"

    fi

    robot merge --input results/merged.owl \
	  --input results/template_StudyDesigns.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_StudyDesigns.owl \
	  --output results/extension.owl


    ## Create Planning Processes

    if [ $verbose -eq 1 ]; then

	echo "Processing planning processes template"

    fi
    
    robot template --template template-planning.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_Planning.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging planning processes"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_Planning.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_Planning.owl \
	  --output results/extension.owl


    ## Create Investigation Processes

    if [ $verbose -eq 1 ]; then

	echo "Processing investigation processes template"

    fi
    
    robot template --template template-investigations.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_Investigations.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging investigation processes"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_Investigations.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_Investigations.owl \
	  --output results/extension.owl


    ## Create Roles

    if [ $verbose -eq 1 ]; then

	echo "Processing roles template"

    fi
    
    robot template --template template-roles.tsv \
	  --prefixes prefixes.json \
	  --input results/merged.owl \
	  --output results/template_roles.owl

    if [ $verbose -eq 1 ]; then

	echo "Merging roles"

    fi
    
    robot merge --input results/merged.owl \
	  --input results/template_roles.owl \
	  --output results/merged.owl

    robot merge --input results/extension.owl \
	  --input results/template_roles.owl \
	  --output results/extension.owl

    


    ## DEFINE OUTPUT FILE
    ## ------------------

    cd results
    
    if [ $full -eq 1 ]; then
	output="merged.owl"
    else
	output="extension.owl"
    fi
    

    ## CLEANUP TEMPORARY FILES
    ## -----------------------

    if [ $cleanup -eq 1 ]; then

	if [ $verbose -eq 1 ]; then
	    echo "Cleaning up temporary files"
	fi
	
	find . -not -regex ./"$output" -delete
    fi


    ## CONSISTENCY TEST
    ## ----------------

    if [ $verbose -eq 1 ]; then

	echo "Testing consistency of output"

    fi
    
    robot reason --reasoner ELK \
	  --input "$output" \
	  -D debug.owl

    
    ## ANNOTATE OUTPUT
    ## ---------------

    if [ $verbose -eq 1 ]; then

	echo "Annotating output"

    fi
    
    robot annotate --input "$output" \
	  --remove-annotations \
	  --output "$output"
    
    creatorsnumber=${#creators[*]}
    for ((i = 0 ; i < $creatorsnumber ; i++)); do

    robot annotate --input "$output" \
		  --annotation dc:creator "${creators[i]}" \
		  --output "$output"

    done
    
    contributorsnumber=${#contributors[*]}
    for ((i = 0 ; i < $contributorsnumber ; i++)); do

	robot annotate --input "$output" \
	  --annotation dc:contributor "${contributors[i]}" \
	  --output "$output"

    done

    robot annotate --input "$output" \
	  --ontology-iri "${ontology_iri}" \
	  --version-iri "${version_iri}" \
	  --annotation owl:versionInfo "${version}" \
	  --annotation dc:date "${date}" \
	  --language-annotation rdfs:label "${title}" en \
	  --language-annotation rdfs:comment "${comment}" en \
	  --language-annotation dc:description "${description}" en \
	  --language-annotation dc:title "${title}" en \
	  --language-annotation dc:source "${source}" en \
	  --output $shortname.owl

    ## Change annotations to describe your extension and change file name in the final output statement.
    ## *************************************************************************************************

    
    ## CLEANUP TEMPORARY FILES
    ## -----------------------

    if [ $cleanup -eq 1 ]; then

	if [ $verbose -eq 1 ]; then
	    echo "Cleaning up temposrary files"
	fi
	
	rm "$output"
    fi

    cd ..

fi


## CLEANUP
## =======


## CLEANUP TEMPORARY FILES IN DEPENDENCIES
## ---------------------------------------

if [ $verbose -eq 1 ]; then

    echo "Cleaning up temporary files in dependencies directories"

fi

## Remove temporary build files in RDFBones core ontology

FILE=dependencies/RDFBones-O/robot/results/
if [ -f "$FILE" ]; then
    rm -r dependencies/RDFBones-O/robot/results/
fi

## Add cleanup commands for additional dependencies as exemplified above for the RDFBones core ontology.
## *****************************************************************************************************
