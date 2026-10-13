require 'erb'

module SequenceServer
  # Module to contain methods for generating sequence retrieval links.
  module Links
    # Provide a method to URL encode _query parameters_. See [1].
    include ERB::Util
    alias encode url_encode

    NCBI_ID_PATTERN    = /gi\|(\d+)\|/
    UNIPROT_ID_PATTERN = /sp\|(\w+)\|/
    PFAM_ID_PATTERN = /(PF\d{5}\.?\d*)/
    RFAM_ID_PATTERN = /(RF\d{5})/
    RAPDB_ID_PATTERN = /(Os\d{2}t\d{7}-\d{2})/
    PHYTOZOME_AT_ID_PATTERN = /(AT.+)/
    PHYTOZOME_HV_ID_PATTERN = /(HORVU.+)\.V3$/
    PHYTOZOME_TA_ID_PATTERN = /(Traes.+)\.v2\.1$/
    PHYTOZOME_GM_ID_PATTERN = /(Glyma.+)\.Wm82\.a6\.v1$/
    PHYTOZOME_SL_ID_PATTERN = /(Solyc.........)/
    PHYTOZOME_PP_ID_PATTERN = /(Prupe\.(?!aktk\.)..........)/
    SEQUON_AC_ID_PATTERN = /(^g\d*\.t\d)/
    FUJIDELICIOUS_ID_PATTERN = /(FujiDel\d{2}g\d+\.t\d+)/
    FUJIRALLS_ID_PATTERN = /(FujiRal\d{2}g\d+\.t\d+)/
    GOLDENDELICIOUS_ID_PATTERN = /((MD\d{2}G\d{7})\.v1\.1\.491)/
    PEACHAKATSUKI_ID_PATTERN = /(Prupe\.aktk\.\d{2}G\d{6}\.01)/
    PEACHLOVELL_ID_PATTERN = /(Prupe\.\dG\d{6}\.1\.v2\.1)/
    PEARAKIZUKI_ID_PATTERN = /(Akizuki\.\d{2}G\d{6}\.01)/
    UNSHIUKISHU_ID_PATTERN = /(CUN\dKi\d{6}\.t1)/
    UNSHIUKUNENBO_ID_PATTERN = /(CUN\dKu\d{6}\.t1)/
    CLEMENTINA_ID_PATTERN = /((Ciclev\d{8}m)\.v1\.0)/
    SHINEMUSCAT_ID_PATTERN = /(VSMuph2\.0_chr\d{2}\.g\d{4}\.i?1)/
    TEASEIMEI_ID_PATTERN = /(CsSME\d{2}G\d{6}\.t1)/
    TEASHUCHAZAO_ID_PATTERN = /(CSS\d{7}\.\d)/
    RAPDB_CHR_PATTERN = /^(OsNPB_chr\d+)$/
    PHYTOZOME_AT_CHR_PATTERN = /^(At_Chr\d+)$/
    PHYTOZOME_GM_CHR_PATTERN = /^(GmWm82_Gm\d+)$/
    FUJIDELICIOUS_CHR_PATTERN = /^(FujiDel_Chr\d+)$/
    FUJIRALLS_CHR_PATTERN = /^(FujiRal_Chr\d+)$/
    GOLDENDELICIOUS_CHR_PATTERN = /^(MdGDDH_Chr\d+)$/
    PEACHAKATSUKI_CHR_PATTERN = /^(PpAkt_Chr\d+)$/
    PEACHLOVELL_CHR_PATTERN = /^(PpLov_Pp\d+)$/
    PEARAKIZUKI_CHR_PATTERN = /^(PpAkz_Chr\d+)$/
    UNSHIUKISHU_CHR_PATTERN = /^(CUNphKi_ch\d+)$/
    UNSHIUKUNENBO_CHR_PATTERN = /^(CUNphKu_ch\d+)$/
    CLEMENTINA_CHR_PATTERN = /^(Ccle_scaffold_\d+)$/
    SHINEMUSCAT_CHR_PATTERN = /^(VSM_chr\d+)$/
    TEASEIMEI_CHR_PATTERN = /^(CsSME_Chr\d+)$/
    TEASHUCHAZAO_CHR_PATTERN = /^(CsSCZ_Chr\d+)$/

    # Link generators are methods that return a Hash as defined below.
    #
    # {
    #   # Required. Display title.
    #   :title => "title",
    #
    #   # Required. Generated url.
    #   :url => url,
    #
    #   # Optional. Left-right order in which the link should appear.
    #   :order => num,
    #
    #   # Optional. Classes, if any, to apply to the link.
    #   :class => "class1 class2",
    #
    #   # Optional. Class name of a FontAwesome icon to use.
    #   :icon => "fa-icon-class"
    # }
    #
    # If no url could be generated, return nil.
    #
    # Helper methods
    # --------------
    #
    # Following helper methods are available to help with link generation.
    #
    #   encode:
    #     URL encode query params.
    #
    #     Don't use this function to encode the entire URL. Only params.
    #
    #     e.g:
    #         sequence_id = encode sequence_id
    #         url = "http://www.ncbi.nlm.nih.gov/nucleotide/#{sequence_id}"
    #
    #   dbtype:
    #     Returns the database type (nucleotide or protein) that was used for
    #     BLAST search.
    #
    #   whichdb:
    #     Returns the databases from which the hit could have originated. To
    #     ensure that one and the correct database is returned, ensure that
    #     your sequence ids are unique across different FASTA files.
    #     NOTE: This method is slow.
    #
    #   coordinates:
    #     Returns min alignment start and max alignment end coordinates for
    #     query and hit sequences.
    #
    #     e.g.,
    #     query_coords = coordinates[0]
    #     hit_coords = coordinates[1]

    def ncbi
      return nil unless id.match(NCBI_ID_PATTERN) or title.match(NCBI_ID_PATTERN)
      ncbi_id = Regexp.last_match[1]
      ncbi_id = encode ncbi_id
      url = "https://www.ncbi.nlm.nih.gov/#{dbtype}/#{ncbi_id}"
      {
        order: 2,
        title: 'NCBI',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def uniprot
      return nil unless id.match(UNIPROT_ID_PATTERN) or title.match(UNIPROT_ID_PATTERN)
      uniprot_id = Regexp.last_match[1]
      uniprot_id = encode uniprot_id
      url = "https://www.uniprot.org/uniprot/#{uniprot_id}"
      {
        order: 2,
        title: 'UniProt',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def pfam
      return nil unless id.match(PFAM_ID_PATTERN) or title.match(PFAM_ID_PATTERN)
      pfam_id = Regexp.last_match[1]
      pfam_id = encode pfam_id
      url = "https://pfam.xfam.org/family/#{pfam_id}"
      {
        order: 2,
        title: 'Pfam',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def rfam
      return nil unless id.match(RFAM_ID_PATTERN) or title.match(RFAM_ID_PATTERN)
      rfam_id = Regexp.last_match[1]
      rfam_id = encode rfam_id
      url = "https://rfam.xfam.org/family/#{rfam_id}"
      {
        order: 2,
        title: 'Rfam',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def rapdb_jbrowse1
      return nil unless id.match(RAPDB_ID_PATTERN) or title.match(RAPDB_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=Rice&loc=#{id}&tracks=DNA%2CRice_0%2CRice_1%2CRice_2"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def rapdb_jbrowse2
      return nil unless id.match(RAPDB_ID_PATTERN) or title.match(RAPDB_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_Rice.json&loc=#{id}&assembly=Rice&tracks=Rice-ReferenceSequenceTrack%2CRice_0%2CRice_1%2CRice_2&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def rapdb
      return nil unless id.match(RAPDB_ID_PATTERN) or title.match(RAPDB_ID_PATTERN)
      rapdb_id = Regexp.last_match[1]
      rapdb_id = encode rapdb_id
      url = "https://rapdb.dna.naro.go.jp/transcript/?name=#{rapdb_id}"
      {
        order: 2,
        title: 'RAP-DB',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_at_jbrowse1
      return nil unless id.match(PHYTOZOME_AT_ID_PATTERN) or title.match(PHYTOZOME_AT_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=Arabidopsis&loc=#{id}&tracks=DNA%2CArabidopsis"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_at_jbrowse2
      return nil unless id.match(PHYTOZOME_AT_ID_PATTERN) or title.match(PHYTOZOME_AT_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_Arabidopsis.json&loc=#{id}&assembly=Arabidopsis&tracks=Arabidopsis-ReferenceSequenceTrack%2CArabidopsis&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_at
      return nil unless id.match(PHYTOZOME_AT_ID_PATTERN) or title.match(PHYTOZOME_AT_ID_PATTERN)
      phytozome_at_id = Regexp.last_match[1]
      phytozome_at_id = encode phytozome_at_id
      url = "https://phytozome-next.jgi.doe.gov/report/transcript/Athaliana_TAIR10/#{phytozome_at_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_hv_jbrowse1
      return nil unless id.match(PHYTOZOME_HV_ID_PATTERN) or title.match(PHYTOZOME_HV_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=Barley&loc=#{id}&tracks=DNA%2CBarley"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_hv
      return nil unless id.match(PHYTOZOME_HV_ID_PATTERN) or title.match(PHYTOZOME_HV_ID_PATTERN)
      phytozome_hv_id = Regexp.last_match[1]
      phytozome_hv_id = encode phytozome_hv_id
      url = "https://phytozome-next.jgi.doe.gov/report/transcript/HvulgareMorex_V3/#{phytozome_hv_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_ta_jbrowse1
      return nil unless id.match(PHYTOZOME_TA_ID_PATTERN) or title.match(PHYTOZOME_TA_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=Wheat&loc=#{id}&tracks=DNA%2CWheat"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_ta
      return nil unless id.match(PHYTOZOME_TA_ID_PATTERN) or title.match(PHYTOZOME_TA_ID_PATTERN)
      phytozome_ta_id = Regexp.last_match[1]
      phytozome_ta_id = encode phytozome_ta_id
      url = "https://phytozome-next.jgi.doe.gov/report/transcript/Taestivumcv_ChineseSpring_v2_1/#{phytozome_ta_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_gm_jbrowse1
      return nil unless id.match(PHYTOZOME_GM_ID_PATTERN) or title.match(PHYTOZOME_GM_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=Soybean&loc=#{id}&tracks=DNA%2CSoybean"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_gm_jbrowse2
      return nil unless id.match(PHYTOZOME_GM_ID_PATTERN) or title.match(PHYTOZOME_GM_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_Soybean.json&loc=#{id}&assembly=Soybean&tracks=Soybean-ReferenceSequenceTrack%2CSoybean&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_gm
      return nil unless id.match(PHYTOZOME_GM_ID_PATTERN) or title.match(PHYTOZOME_GM_ID_PATTERN)
      phytozome_gm_id = Regexp.last_match[1]
      phytozome_gm_id = encode phytozome_gm_id
      url = "https://phytozome-next.jgi.doe.gov/report/transcript/Gmax_Wm82_a6_v1/#{phytozome_gm_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_sl_jbrowse1
      return nil unless id.match(PHYTOZOME_SL_ID_PATTERN) or title.match(PHYTOZOME_SL_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=Tomato&loc=#{id}&tracks=DNA%2CTomato"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_sl
      return nil unless id.match(PHYTOZOME_SL_ID_PATTERN) or title.match(PHYTOZOME_SL_ID_PATTERN)
      phytozome_sl_id = Regexp.last_match[1]
      phytozome_sl_id = encode phytozome_sl_id
      url = "https://phytozome-next.jgi.doe.gov/report/gene/Slycopersicum_ITAG4_0/#{phytozome_sl_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_pp
      return nil unless id.match(PHYTOZOME_PP_ID_PATTERN) or title.match(PHYTOZOME_PP_ID_PATTERN)
      phytozome_pp_id = Regexp.last_match[1]
      phytozome_pp_id = encode phytozome_pp_id
      url = "https://phytozome-next.jgi.doe.gov/report/transcript/Ppersica_v2_1/#{phytozome_pp_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def sequon_ac_jbrowse1
      return nil unless id.match(SEQUON_AC_ID_PATTERN) or title.match(SEQUON_AC_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=Onion&loc=#{id}&tracks=DNA%2COnion"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def fujidelicious_jbrowse1
      return nil unless id.match(FUJIDELICIOUS_ID_PATTERN) or title.match(FUJIDELICIOUS_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=FujiDelicious&loc=#{id}&tracks=DNA%2CFujiDelicious"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def fujidelicious_jbrowse2
      return nil unless id.match(FUJIDELICIOUS_ID_PATTERN) or title.match(FUJIDELICIOUS_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_FujiDelicious.json&loc=#{id}&assembly=FujiDelicious&tracks=FujiDelicious-ReferenceSequenceTrack%2CFujiDelicious&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def fujiralls_jbrowse1
      return nil unless id.match(FUJIRALLS_ID_PATTERN) or title.match(FUJIRALLS_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=FujiRalls&loc=#{id}&tracks=DNA%2CFujiRalls"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def fujiralls_jbrowse2
      return nil unless id.match(FUJIRALLS_ID_PATTERN) or title.match(FUJIRALLS_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_FujiRalls.json&loc=#{id}&assembly=FujiRalls&tracks=FujiRalls-ReferenceSequenceTrack%2CFujiRalls&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def goldendelicious_jbrowse1
      return nil unless id.match(GOLDENDELICIOUS_ID_PATTERN) or title.match(GOLDENDELICIOUS_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=GoldenDelicious&loc=#{id}&tracks=DNA%2CGoldenDelicious"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def goldendelicious_jbrowse2
      return nil unless id.match(GOLDENDELICIOUS_ID_PATTERN) or title.match(GOLDENDELICIOUS_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_GoldenDelicious.json&loc=#{id}&assembly=GoldenDelicious&tracks=GoldenDelicious-ReferenceSequenceTrack%2CGoldenDelicious&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def goldendelicious_phytozome
      return nil unless id.match(GOLDENDELICIOUS_ID_PATTERN) or title.match(GOLDENDELICIOUS_ID_PATTERN)
      phytozome_id = Regexp.last_match[2]
      phytozome_id = encode phytozome_id
      url = "https://phytozome-next.jgi.doe.gov/report/transcript/Mdomestica_v1_1/#{phytozome_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def peachakatsuki_jbrowse1
      return nil unless id.match(PEACHAKATSUKI_ID_PATTERN) or title.match(PEACHAKATSUKI_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=PeachAkatsuki&loc=#{id}&tracks=DNA%2CPeachAkatsuki"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def peachakatsuki_jbrowse2
      return nil unless id.match(PEACHAKATSUKI_ID_PATTERN) or title.match(PEACHAKATSUKI_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_PeachAkatsuki.json&loc=#{id}&assembly=PeachAkatsuki&tracks=PeachAkatsuki-ReferenceSequenceTrack%2CPeachAkatsuki&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def peachlovell_jbrowse1
      return nil unless id.match(PEACHLOVELL_ID_PATTERN) or title.match(PEACHLOVELL_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=PeachLovell&loc=#{id}&tracks=DNA%2CPeachLovell"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def peachlovell_jbrowse2
      return nil unless id.match(PEACHLOVELL_ID_PATTERN) or title.match(PEACHLOVELL_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_PeachLovell.json&loc=#{id}&assembly=PeachLovell&tracks=PeachLovell-ReferenceSequenceTrack%2CPeachLovell&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def pearakizuki_jbrowse1
      return nil unless id.match(PEARAKIZUKI_ID_PATTERN) or title.match(PEARAKIZUKI_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=PearAkizuki&loc=#{id}&tracks=DNA%2CPearAkizuki"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def pearakizuki_jbrowse2
      return nil unless id.match(PEARAKIZUKI_ID_PATTERN) or title.match(PEARAKIZUKI_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_PearAkizuki.json&loc=#{id}&assembly=PearAkizuki&tracks=PearAkizuki-ReferenceSequenceTrack%2CPearAkizuki&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def unshiukishu_jbrowse1
      return nil unless id.match(UNSHIUKISHU_ID_PATTERN) or title.match(UNSHIUKISHU_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=UnshiuKishu&loc=#{id}&tracks=DNA%2CUnshiuKishu"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def unshiukishu_jbrowse2
      return nil unless id.match(UNSHIUKISHU_ID_PATTERN) or title.match(UNSHIUKISHU_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_UnshiuKishu.json&loc=#{id}&assembly=UnshiuKishu&tracks=UnshiuKishu-ReferenceSequenceTrack%2CUnshiuKishu&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def unshiukunenbo_jbrowse1
      return nil unless id.match(UNSHIUKUNENBO_ID_PATTERN) or title.match(UNSHIUKUNENBO_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=UnshiuKunenbo&loc=#{id}&tracks=DNA%2CUnshiuKunenbo"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def unshiukunenbo_jbrowse2
      return nil unless id.match(UNSHIUKUNENBO_ID_PATTERN) or title.match(UNSHIUKUNENBO_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_UnshiuKunenbo.json&loc=#{id}&assembly=UnshiuKunenbo&tracks=UnshiuKunenbo-ReferenceSequenceTrack%2CUnshiuKunenbo&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def clementina_jbrowse1
      return nil unless id.match(CLEMENTINA_ID_PATTERN) or title.match(CLEMENTINA_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=Clementina&loc=#{id}&tracks=DNA%2CClementina"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def clementina_jbrowse2
      return nil unless id.match(CLEMENTINA_ID_PATTERN) or title.match(CLEMENTINA_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_Clementina.json&loc=#{id}&assembly=Clementina&tracks=Clementina-ReferenceSequenceTrack%2CClementina&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def clementina_phytozome
      return nil unless id.match(CLEMENTINA_ID_PATTERN) or title.match(CLEMENTINA_ID_PATTERN)
      phytozome_id = Regexp.last_match[2]
      phytozome_id = encode phytozome_id
      url = "https://phytozome-next.jgi.doe.gov/report/transcript/Cclementina_v1_0/#{phytozome_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def shinemuscat_jbrowse1
      return nil unless id.match(SHINEMUSCAT_ID_PATTERN) or title.match(SHINEMUSCAT_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=ShineMuscat&loc=#{id}&tracks=DNA%2CShineMuscat"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def shinemuscat_jbrowse2
      return nil unless id.match(SHINEMUSCAT_ID_PATTERN) or title.match(SHINEMUSCAT_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_ShineMuscat.json&loc=#{id}&assembly=ShineMuscat&tracks=ShineMuscat-ReferenceSequenceTrack%2CShineMuscat&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def teaseimei_jbrowse1
      return nil unless id.match(TEASEIMEI_ID_PATTERN) or title.match(TEASEIMEI_ID_PATTERN)
      url = "/fruiteagdb/jbrowse/?data=TeaSeimei&loc=#{id}&tracks=DNA%2CTeaSeimei"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def teaseimei_jbrowse2
      return nil unless id.match(TEASEIMEI_ID_PATTERN) or title.match(TEASEIMEI_ID_PATTERN)
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_TeaSeimei.json&loc=#{id}&assembly=TeaSeimei&tracks=TeaSeimei-ReferenceSequenceTrack%2CTeaSeimei&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def teashuchazao_jbrowse1
      return nil unless id.match(TEASHUCHAZAO_ID_PATTERN) or title.match(TEASHUCHAZAO_ID_PATTERN)
      teashuchazao_id = Regexp.last_match[1]
      url = "/fruiteagdb/jbrowse/?data=TeaShuchazao&loc=#{teashuchazao_id}&tracks=DNA%2CTeaShuchazao"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def teashuchazao_jbrowse2
      return nil unless id.match(TEASHUCHAZAO_ID_PATTERN) or title.match(TEASHUCHAZAO_ID_PATTERN)
      teashuchazao_id = Regexp.last_match[1]
      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_TeaShuchazao.json&loc=#{teashuchazao_id}&assembly=TeaShuchazao&tracks=TeaShuchazao-ReferenceSequenceTrack%2CTeaShuchazao&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def rapdb_chr_jbrowse1
      return nil unless id.match(RAPDB_CHR_PATTERN)
      rapdb_chr = Regexp.last_match[1]
      rapdb_chr = encode rapdb_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=Rice" \
      "&loc=#{rapdb_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{rapdb_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CRice_0%2CRice_1%2CRice_2"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def rapdb_chr_jbrowse2
      return nil unless id.match(RAPDB_CHR_PATTERN)
      rapdb_chr = Regexp.last_match[1]
      rapdb_chr = encode rapdb_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_Rice.json" \
      "&loc=#{rapdb_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{rapdb_chr}%3A#{best_start}..#{best_end}&assembly=Rice" \
      "&tracks=Rice-ReferenceSequenceTrack%2CRice_0%2CRice_1%2CRice_2&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def phytozome_at_chr_jbrowse1
      return nil unless id.match(PHYTOZOME_AT_CHR_PATTERN)
      arabidopsis_chr = Regexp.last_match[1]
      arabidopsis_chr = encode arabidopsis_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=Arabidopsis" \
      "&loc=#{arabidopsis_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{arabidopsis_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CArabidopsis"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def phytozome_at_chr_jbrowse2
      return nil unless id.match(PHYTOZOME_AT_CHR_PATTERN)
      arabidopsis_chr = Regexp.last_match[1]
      arabidopsis_chr = encode arabidopsis_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_Arabidopsis.json" \
      "&loc=#{arabidopsis_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{arabidopsis_chr}%3A#{best_start}..#{best_end}&assembly=Arabidopsis" \
      "&tracks=Arabidopsis-ReferenceSequenceTrack%2CArabidopsis&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def phytozome_gm_chr_jbrowse1
      return nil unless id.match(PHYTOZOME_GM_CHR_PATTERN)
      soybean_chr = Regexp.last_match[1]
      soybean_chr = encode soybean_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=Soybean" \
      "&loc=#{soybean_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{soybean_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CSoybean"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def phytozome_gm_chr_jbrowse2
      return nil unless id.match(PHYTOZOME_GM_CHR_PATTERN)
      soybean_chr = Regexp.last_match[1]
      soybean_chr = encode soybean_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_Soybean.json" \
      "&loc=#{soybean_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{soybean_chr}%3A#{best_start}..#{best_end}&assembly=Soybean" \
      "&tracks=Soybean-ReferenceSequenceTrack%2CSoybean&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def fujidelicious_chr_jbrowse1
      return nil unless id.match(FUJIDELICIOUS_CHR_PATTERN)
      fujidel_chr = Regexp.last_match[1]
      fujidel_chr = encode fujidel_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=FujiDelicious" \
      "&loc=#{fujidel_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{fujidel_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CFujiDelicious"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def fujidelicious_chr_jbrowse2
      return nil unless id.match(FUJIDELICIOUS_CHR_PATTERN)
      fujidel_chr = Regexp.last_match[1]
      fujidel_chr = encode fujidel_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_FujiDelicious.json" \
      "&loc=#{fujidel_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{fujidel_chr}%3A#{best_start}..#{best_end}&assembly=FujiDelicious" \
      "&tracks=FujiDelicious-ReferenceSequenceTrack%2CFujiDelicious&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def fujiralls_chr_jbrowse1
      return nil unless id.match(FUJIRALLS_CHR_PATTERN)
      fujiral_chr = Regexp.last_match[1]
      fujiral_chr = encode fujiral_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=FujiRalls" \
      "&loc=#{fujiral_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{fujiral_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CFujiRalls"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def fujiralls_chr_jbrowse2
      return nil unless id.match(FUJIRALLS_CHR_PATTERN)
      fujiral_chr = Regexp.last_match[1]
      fujiral_chr = encode fujiral_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_FujiRalls.json" \
      "&loc=#{fujiral_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{fujiral_chr}%3A#{best_start}..#{best_end}&assembly=FujiRalls" \
      "&tracks=FujiRalls-ReferenceSequenceTrack%2CFujiRalls&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def goldendelicious_chr_jbrowse1
      return nil unless id.match(GOLDENDELICIOUS_CHR_PATTERN)
      goldendel_chr = Regexp.last_match[1]
      goldendel_chr = encode goldendel_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=GoldenDelicious" \
      "&loc=#{goldendel_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{goldendel_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CGoldenDelicious"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def goldendelicious_chr_jbrowse2
      return nil unless id.match(GOLDENDELICIOUS_CHR_PATTERN)
      goldendel_chr = Regexp.last_match[1]
      goldendel_chr = encode goldendel_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_GoldenDelicious.json" \
      "&loc=#{goldendel_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{goldendel_chr}%3A#{best_start}..#{best_end}&assembly=GoldenDelicious" \
      "&tracks=GoldenDelicious-ReferenceSequenceTrack%2CGoldenDelicious&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def peachakatsuki_chr_jbrowse1
      return nil unless id.match(PEACHAKATSUKI_CHR_PATTERN)
      akatsuki_chr = Regexp.last_match[1]
      akatsuki_chr = encode akatsuki_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=PeachAkatsuki" \
      "&loc=#{akatsuki_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{akatsuki_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CPeachAkatsuki"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def peachakatsuki_chr_jbrowse2
      return nil unless id.match(PEACHAKATSUKI_CHR_PATTERN)
      akatsuki_chr = Regexp.last_match[1]
      akatsuki_chr = encode akatsuki_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_PeachAkatsuki.json" \
      "&loc=#{akatsuki_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{akatsuki_chr}%3A#{best_start}..#{best_end}&assembly=PeachAkatsuki" \
      "&tracks=PeachAkatsuki-ReferenceSequenceTrack%2CPeachAkatsuki&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def peachlovell_chr_jbrowse1
      return nil unless id.match(PEACHLOVELL_CHR_PATTERN)
      lovell_chr = Regexp.last_match[1]
      lovell_chr = encode lovell_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=PeachLovell" \
      "&loc=#{lovell_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{lovell_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CPeachLovell"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def peachlovell_chr_jbrowse2
      return nil unless id.match(PEACHLOVELL_CHR_PATTERN)
      lovell_chr = Regexp.last_match[1]
      lovell_chr = encode lovell_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_PeachLovell.json" \
      "&loc=#{lovell_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{lovell_chr}%3A#{best_start}..#{best_end}&assembly=PeachLovell" \
      "&tracks=PeachLovell-ReferenceSequenceTrack%2CPeachLovell&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def pearakizuki_chr_jbrowse2
      return nil unless id.match(PEARAKIZUKI_CHR_PATTERN)
      akizuki_chr = Regexp.last_match[1]
      akizuki_chr = encode akizuki_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_PearAkizuki.json&loc=#{akizuki_chr}%3A#{best_start}..#{best_end}&highlight=#{akizuki_chr}%3A#{best_start}..#{best_end}&assembly=PearAkizuki&tracks=PearAkizuki-ReferenceSequenceTrack%2CPearAkizuki&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def unshiukishu_chr_jbrowse1
      return nil unless id.match(UNSHIUKISHU_CHR_PATTERN)
      unshiukishu_chr = Regexp.last_match[1]
      unshiukishu_chr = encode unshiukishu_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=UnshiuKishu" \
      "&loc=#{unshiukishu_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{unshiukishu_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CUnshiuKishu"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def unshiukishu_chr_jbrowse2
      return nil unless id.match(UNSHIUKISHU_CHR_PATTERN)
      unshiukishu_chr = Regexp.last_match[1]
      unshiukishu_chr = encode unshiukishu_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_UnshiuKishu.json" \
      "&loc=#{unshiukishu_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{unshiukishu_chr}%3A#{best_start}..#{best_end}&assembly=UnshiuKishu" \
      "&tracks=UnshiuKishu-ReferenceSequenceTrack%2CUnshiuKishu&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def unshiukunenbo_chr_jbrowse1
      return nil unless id.match(UNSHIUKUNENBO_CHR_PATTERN)
      unshiukunenbo_chr = Regexp.last_match[1]
      unshiukunenbo_chr = encode unshiukunenbo_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=UnshiuKunenbo" \
      "&loc=#{unshiukunenbo_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{unshiukunenbo_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CUnshiuKunenbo"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def unshiukunenbo_chr_jbrowse2
      return nil unless id.match(UNSHIUKUNENBO_CHR_PATTERN)
      unshiukunenbo_chr = Regexp.last_match[1]
      unshiukunenbo_chr = encode unshiukunenbo_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_UnshiuKunenbo.json" \
      "&loc=#{unshiukunenbo_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{unshiukunenbo_chr}%3A#{best_start}..#{best_end}&assembly=UnshiuKunenbo" \
      "&tracks=UnshiuKunenbo-ReferenceSequenceTrack%2CUnshiuKunenbo&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def clementina_chr_jbrowse1
      return nil unless id.match(CLEMENTINA_CHR_PATTERN)
      clementina_chr = Regexp.last_match[1]
      clementina_chr = encode clementina_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=Clementina" \
      "&loc=#{clementina_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{clementina_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CClementina"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def clementina_chr_jbrowse2
      return nil unless id.match(CLEMENTINA_CHR_PATTERN)
      clementina_chr = Regexp.last_match[1]
      clementina_chr = encode clementina_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_Clementina.json" \
      "&loc=#{clementina_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{clementina_chr}%3A#{best_start}..#{best_end}&assembly=Clementina" \
      "&tracks=Clementina-ReferenceSequenceTrack%2CClementina&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def shinemuscat_chr_jbrowse1
      return nil unless id.match(SHINEMUSCAT_CHR_PATTERN)
      shinemuscat_chr = Regexp.last_match[1]
      shinemuscat_chr = encode shinemuscat_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=ShineMuscat" \
      "&loc=#{shinemuscat_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{shinemuscat_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CShineMuscat"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def shinemuscat_chr_jbrowse2
      return nil unless id.match(SHINEMUSCAT_CHR_PATTERN)
      shinemuscat_chr = Regexp.last_match[1]
      shinemuscat_chr = encode shinemuscat_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_ShineMuscat.json" \
      "&loc=#{shinemuscat_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{shinemuscat_chr}%3A#{best_start}..#{best_end}&assembly=ShineMuscat" \
      "&tracks=ShineMuscat-ReferenceSequenceTrack%2CShineMuscat&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def teaseimei_chr_jbrowse1
      return nil unless id.match(TEASEIMEI_CHR_PATTERN)
      teaseimei_chr = Regexp.last_match[1]
      teaseimei_chr = encode teaseimei_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=TeaSeimei" \
      "&loc=#{teaseimei_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{teaseimei_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CTeaSeimei"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def teaseimei_chr_jbrowse2
      return nil unless id.match(TEASEIMEI_CHR_PATTERN)
      teaseimei_chr = Regexp.last_match[1]
      teaseimei_chr = encode teaseimei_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_TeaSeimei.json" \
      "&loc=#{teaseimei_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{teaseimei_chr}%3A#{best_start}..#{best_end}&assembly=TeaSeimei" \
      "&tracks=TeaSeimei-ReferenceSequenceTrack%2CTeaSeimei&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def teashuchazao_chr_jbrowse1
      return nil unless id.match(TEASHUCHAZAO_CHR_PATTERN)
      teashuchazao_chr = Regexp.last_match[1]
      teashuchazao_chr = encode teashuchazao_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/fruiteagdb/jbrowse/?data=TeaShuchazao" \
      "&loc=#{teashuchazao_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{teashuchazao_chr}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CTeaShuchazao"

      {
        :order => 2,
        :title => 'JBrowse1 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def teashuchazao_chr_jbrowse2
      return nil unless id.match(TEASHUCHAZAO_CHR_PATTERN)
      teashuchazao_chr = Regexp.last_match[1]
      teashuchazao_chr = encode teashuchazao_chr

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end
      if best_start > best_end
          dummy      = best_start
          best_start = best_end
          best_end   = dummy
      end

      url = "/fruiteagdb/jbrowse2/?config=data%2Fcf_TeaShuchazao.json" \
      "&loc=#{teashuchazao_chr}%3A#{best_start}..#{best_end}" \
      "&highlight=#{teashuchazao_chr}%3A#{best_start}..#{best_end}&assembly=TeaShuchazao" \
      "&tracks=TeaShuchazao-ReferenceSequenceTrack%2CTeaShuchazao&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end
  end
end

# [1]: https://stackoverflow.com/questions/2824126/whats-the-difference-between-uri-escape-and-cgi-escape
