// Include dependencies
if (params.distance == 'near'){
    include {gsalign_near as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'medium'){
    include {gsalign_medium as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'far') {
    include {gsalign_far as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'custom') {
    include {gsalign_custom as gsalign} from '../processes/GSAlign'
} else if (params.distance == 'same') {
    include {gsalign_balanced as gsalign} from '../processes/GSAlign'
}
include {axtchain; chainMerge; chainNet} from "../processes/postprocess"

// Prepare input channels
if (params.source) { ch_source = file(params.source) } else { exit 1, 'Source genome not specified!' }
if (params.target) { ch_target = file(params.target) } else { exit 1, 'Target genome not specified!' }
if (params.annotation) { ch_annot = file(params.annotation) } else { log.info 'No annotation given' }

// Create gsalign alignments workflow
workflow GSALIGN {
    take:
        pairspath_ch
        tgt_lift
        src_lift
        twoBitS
        twoBitT
        twoBitSN
        twoBitTN  

    main:

        // Run gsalign
        gsalign(pairspath_ch, tgt_lift, src_lift)  
        axtchain( gsalign.out.al_files_ch, twoBitS, twoBitT)   

        // 
        chainMerge( axtchain.out.collect() )
        chainNet( chainMerge.out, twoBitS, twoBitT, twoBitSN, twoBitTN )
        
    emit:
        chainNet.out.liftover_ch
        chainNet.out.netfile_ch
}
