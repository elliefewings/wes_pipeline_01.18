20Mar2017, Ellie Fewings

Version p05A_wes_genotype_vqsr in wes_pipeline_08.16

Changes annotations used when building vqsr model as some annotations do not allow small number of samples. Use this script when running sample sets of < 5

"annotations_for_vqsr_model: QD MQ MQRankSum ReadPosRankSum FS SOR"