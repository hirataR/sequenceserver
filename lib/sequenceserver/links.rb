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
    RAPDB_ID_PATTERN = /(^Os\d{2}t\d{7}-\d{2})/
    PHYTOZOME_AT_ID_PATTERN = /(^AT.+)/
    PHYTOZOME_HV_ID_PATTERN = /(^HORVU.+)\.V3$/
    PHYTOZOME_TA_ID_PATTERN = /(^Traes.+)\.v2\.1$/
    PHYTOZOME_GM_ID_PATTERN = /(^Glyma.+)\.Wm82\.a6\.v1$/
    PHYTOZOME_ZM_ID_PATTERN = /(^Zm.+)\.Zm_.*$/
    QUINOA_ID_PATTERN = /(^SHCq.+)/
    VIGNA_ID_PATTERN = /(^Vigma.+)/
    RAPDB_CHR_ID_PATTERN = /^(chr\d{2}|Mt|Pt|Syng_\d{3}|AP\d{6}\.\d+|AC\d{6}\.\d+)$/

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
      case ENV['DB']
      when 'main'
        url = "/jbrowse/?data=data%2Firgsp1&loc=#{id}"
      when 'ModelCrops'
        url = "/ModelCrops/jbrowse/?data=Rice&loc=#{id}&tracks=DNA%2CRice_0%2CRice_1%2CRice_2"
      when 'genomedb_rapdb'
        url = "/genomedb_rapdb/jbrowse/?data=Nipponbare&loc=#{id}&tracks=DNA%2CNipponbare_0%2CNipponbare_1%2CNipponbare_2"
      when 'genomedb_ms'
        url = "/genomedb_ms/jbrowse/?data=NPB&loc=#{id}&tracks=DNA%2CNPB_0%2CNPB_1%2CNPB_2"
      else
        return nil
      end
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def rapdb_jbrowse2
      return nil unless id.match(RAPDB_ID_PATTERN) or title.match(RAPDB_ID_PATTERN)
      case ENV['DB']
      when 'main'
        url = "/jbrowse2/?config=data%2Firgsp1.json&loc=#{id}&assembly=genome&tracks=genome-ReferenceSequenceTrack%2Cirgsp1_rep_transcript.sorted.gff%2Cirgsp1_prediction_transcript.sorted.gff&tracklist=true"
      when 'ModelCrops'
        url = "/ModelCrops/jbrowse2/?config=data%2Fcf_Rice.json&loc=#{id}&assembly=Rice&tracks=Rice-ReferenceSequenceTrack%2CRice_0%2CRice_1%2CRice_2&tracklist=true"
      when 'genomedb_rapdb'
        url = "/genomedb_rapdb/jbrowse2/?config=data%2Fcf_Nipponbare.json&loc=#{id}&assembly=Nipponbare&tracks=Nipponbare-ReferenceSequenceTrack%2CNipponbare_0%2CNipponbare_1%2CNipponbare_2&tracklist=true"
      when 'genomedb_ms'
        url = "/genomedb_ms/jbrowse2/?config=data%2Fcf_NPB.json&loc=#{id}&assembly=NPB&tracks=NPB-ReferenceSequenceTrack%2CNPB_0%2CNPB_1%2CNPB_2&tracklist=true"
      else
        return nil
      end
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

    def rapdb_jbrowse1_with_blast
      return nil if id.match(RAPDB_ID_PATTERN) or title.match(RAPDB_ID_PATTERN)
      case ENV['DB']
      when 'main'
        url = "/jbrowse/?data=data%2Firgsp1"
      when 'ModelCrops'
        url = "/ModelCrops/jbrowse/?data=Rice&tracks=DNA%2CRice_0%2CRice_1%2CRice_2"
      when 'genomedb_rapdb'
        url = "/genomedb_rapdb/jbrowse/?data=Nipponbare&tracks=DNA%2CNipponbare_0%2CNipponbare_1%2CNipponbare_2"
      when 'genomedb_ms'
        url = "/genomedb_ms/jbrowse/?data=NPB&tracks=DNA%2CNPB_0%2CNPB_1%2CNPB_2"
      else
        return nil
      end

      qstart = hsps.map(&:qstart).min
      sstart = hsps.map(&:sstart).min
      qend = hsps.map(&:qend).max
      send = hsps.map(&:send).max
      first_hit_start = hsps.map(&:sstart).at(0)
      first_hit_end = hsps.map(&:send).at(0)

      first_hsp = hsps.first
      hit_len = (first_hit_end - first_hit_start).abs
      view_start = [first_hsp.sstart, first_hsp.send].min - (hit_len * 0.1).to_i
      view_end   = [first_hsp.sstart, first_hsp.send].max   + (hit_len * 0.1).to_i
      strand = (first_hsp.send - first_hsp.sstart) < 0 ? "-1" : "1"

      my_features = ERB::Util.url_encode(JSON.generate(
        hsps.first(1).map do |hsp|
          {
            :seq_id => id,
            :start  => [hsp.sstart, hsp.send].min - 1,
            :end    => [hsp.sstart, hsp.send].max,
            :strand => (hsp.send - hsp.sstart) < 0 ? "-1" : "1",
            :name   => "HSP##{hsp.number}"
          }
        end
      ))
      my_track = ERB::Util.url_encode(JSON.generate([
          {
              :label => "BLAST",
              :type => "JBrowse/View/Track/CanvasFeatures",
              :store => "url",
              :style => {
                  :color => "aqua"
              }
          }
      ]))
      url = "#{url}" \
                  "&loc=#{id}:#{view_start}..#{view_end}" \
                  "&addFeatures=#{my_features}" \
                  "&addTracks=#{my_track}"
      {
        :order => 2,
        :title => 'JBrowse1 (Best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def phytozome_at_jbrowse1
      return nil unless id.match(PHYTOZOME_AT_ID_PATTERN) or title.match(PHYTOZOME_AT_ID_PATTERN)
      url = "../jbrowse/?data=Arabidopsis&loc=#{id}&tracks=DNA%2CArabidopsis"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_at_jbrowse2
      return nil unless id.match(PHYTOZOME_AT_ID_PATTERN) or title.match(PHYTOZOME_AT_ID_PATTERN)
      url = "/ModelCrops/jbrowse2/?config=data%2Fcf_Arabidopsis.json&loc=#{id}&assembly=Arabidopsis&tracks=Arabidopsis-ReferenceSequenceTrack%2CArabidopsis&tracklist=true"
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
      url = "../jbrowse/?data=Barley&loc=#{id}&tracks=DNA%2CBarley"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_hv_jbrowse2
      return nil unless id.match(PHYTOZOME_HV_ID_PATTERN) or title.match(PHYTOZOME_HV_ID_PATTERN)
      url = "/ModelCrops/jbrowse2/?config=data%2Fcf_Barley.json&loc=#{id}&assembly=Barley&tracks=Barley-ReferenceSequenceTrack%2CBarley&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
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
      url = "../jbrowse/?data=Wheat&loc=#{id}&tracks=DNA%2CWheat"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_ta_jbrowse2
      return nil unless id.match(PHYTOZOME_TA_ID_PATTERN) or title.match(PHYTOZOME_TA_ID_PATTERN)
      url = "/ModelCrops/jbrowse2/?config=data%2Fcf_Wheat.json&loc=#{id}&assembly=Wheat&tracks=Wheat-ReferenceSequenceTrack%2CWheat&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
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
      url = "../jbrowse/?data=Soybean&loc=#{id}&tracks=DNA%2CSoybean"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_gm_jbrowse2
      return nil unless id.match(PHYTOZOME_GM_ID_PATTERN) or title.match(PHYTOZOME_GM_ID_PATTERN)
      url = "/ModelCrops/jbrowse2/?config=data%2Fcf_Soybean.json&loc=#{id}&assembly=Soybean&tracks=Soybean-ReferenceSequenceTrack%2CSoybean&tracklist=true"
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

    def phytozome_zm_jbrowse1
      return nil unless id.match(PHYTOZOME_ZM_ID_PATTERN) or title.match(PHYTOZOME_ZM_ID_PATTERN)
      url = "../jbrowse/?data=Corn&loc=#{id}&tracks=DNA%2CCorn"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_zm_jbrowse2
      return nil unless id.match(PHYTOZOME_ZM_ID_PATTERN) or title.match(PHYTOZOME_ZM_ID_PATTERN)
      url = "/ModelCrops/jbrowse2/?config=data%2Fcf_Corn.json&loc=#{id}&assembly=Corn&tracks=Corn-ReferenceSequenceTrack%2CCorn&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def phytozome_zm
      return nil unless id.match(PHYTOZOME_ZM_ID_PATTERN) or title.match(PHYTOZOME_ZM_ID_PATTERN)
      phytozome_zm_id = Regexp.last_match[1]
      phytozome_zm_id = encode phytozome_zm_id
      url = "https://phytozome-next.jgi.doe.gov/report/transcript/Zmays_Zm_B73_REFERENCE_NAM_5_0_55/#{phytozome_zm_id}"
      {
        order: 2,
        title: 'Phytozome',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def quinoa_jbrowse1
      return nil unless id.match(QUINOA_ID_PATTERN) or title.match(QUINOA_ID_PATTERN)
      url = "../jbrowse/?data=Cquinoa&loc=#{id}&tracks=DNA%2CCquinoa"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def quinoa_jbrowse2
      return nil unless id.match(QUINOA_ID_PATTERN) or title.match(QUINOA_ID_PATTERN)
      url = "/ModelCrops/jbrowse2/?config=data%2Fcf_Cquinoa.json&loc=#{id}&assembly=Cquinoa&tracks=Cquinoa-ReferenceSequenceTrack%2CCquinoa&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def quinoa_plantgarden
      return nil unless id.match(QUINOA_ID_PATTERN) or title.match(QUINOA_ID_PATTERN)
      quinoa_plantgarden_id = Regexp.last_match[1]
      quinoa_plantgarden_id = encode quinoa_plantgarden_id
      url = "https://plantgarden.jp/ja/list/t63459/genome/t63459.G006/#{quinoa_plantgarden_id}"
      {
        order: 2,
        title: 'Plantgarden',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def vigna_jbrowse1
      return nil unless id.match(VIGNA_ID_PATTERN) or title.match(VIGNA_ID_PATTERN)
      url = "../jbrowse/?data=VignaMarina&loc=#{id}&tracks=DNA%2CVignaMarina"
      {
        order: 2,
        title: 'JBrowse1',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def vigna_jbrowse2
      return nil unless id.match(VIGNA_ID_PATTERN) or title.match(VIGNA_ID_PATTERN)
      url = "/ModelCrops/jbrowse2/?config=data%2Fcf_VignaMarina.json&loc=#{id}&assembly=VignaMarina&tracks=VignaMarina-ReferenceSequenceTrack%2CVignaMarina&tracklist=true"
      {
        order: 2,
        title: 'JBrowse2',
        url:   url,
        icon:  'fa-external-link'
      }
    end

    def vigna_viggs
      return nil unless id.match(VIGNA_ID_PATTERN) or title.match(VIGNA_ID_PATTERN)
      vigna_viggs_id = Regexp.last_match[1]
      vigna_viggs_id = encode vigna_viggs_id
      url = "https://viggs.dna.naro.go.jp/jbrowse/?data=marina_v2a1&loc=#{vigna_viggs_id}"
      {
        order: 2,
        title: 'Viggs',
        url:   url,
        icon:  'fa-external-link'
      }
    end
  end
end

# [1]: https://stackoverflow.com/questions/2824126/whats-the-difference-between-uri-escape-and-cgi-escape
