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
    C_unshiu_Gene_ID_PATTERN = /^(C_unshiu_\d+:mRNA_\d+\.\d+)$/
    C_unshiu_Scaffold_ID_PATTERN = /^(C_unshiu_\d+)$/
    P_trifoliata_Gene_ID_PATTERN = /^(P_trifoliata_(\d+):mRNA_\d+\.\d+)$/
    P_trifoliata_Scaffold_ID_PATTERN = /^(P_trifoliata_\d+)$/
    C_clementina_ID_PATTERN = /^(?!C_clementina_scaffold)^(C_clementina_)(.+$)/
    C_sinensis_ID_PATTERN = /^(?!C_sinensis_chr)^(C_sinensis_)(.+$)/
    CUNphKi_ID_PATTERN = /^((CUN|CUNUn)\d+Ki\d+\..+)$/
    CUNphKu_ID_PATTERN = /^((CUN|CUNUn)\d+Ku\d+\..+)$/
    CKIhap1_ID_PATTERN = /^((CKI|CKIUn)\d+A\d+\..+)$/
    CKIhap2_ID_PATTERN = /^((CKI|CKIUn)\d+B\d+\..+)$/
    CKUhap1_ID_PATTERN = /^((CKU|CKUUn)\d+A\d+\..+)$/
    CKUhap2_ID_PATTERN = /^((CKU|CKUUn)\d+B\d+\..+)$/
    CUNphKi_CHR_PATTERN = /^(CUNphKi_r2\.0ch\d+)$/
    CUNphKu_CHR_PATTERN = /^(CUNphKu_r2\.0ch\d+)$/
    CKIhap1_CHR_PATTERN = /^(CKIhap1_r2\.0ch\d+)$/
    CKIhap2_CHR_PATTERN = /^(CKIhap2_r2\.0ch\d+)$/
    CKUhap1_CHR_PATTERN = /^(CKUhap1_r2\.0ch\d+)$/
    CKUhap2_CHR_PATTERN = /^(CKUhap2_r2\.0ch\d+)$/

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

    def c_unshiu_gene_jbrowse
      return nil unless id.match(C_unshiu_Gene_ID_PATTERN)
      c_unshiu_gene_id = Regexp.last_match[1]
      c_unshiu_gene_id = encode c_unshiu_gene_id

      url = "/jbrowse/?data=data%2Fjson%2FC_unshiu" \
      "&loc=#{c_unshiu_gene_id}" \
      "&tracks=DNA%2CMEGANTE%2CCicle_mRNA_by_GMAP%2CPASA%2CSpaln_SwissProt%2CSpaln_TrEMBL%2Crepeat_region%2Crepeat_unit"

      {
        :order => 2,
        :title => 'JBrowse (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def c_unshiu_scaffold_jbrowse
      return nil unless id.match(C_unshiu_Scaffold_ID_PATTERN)
      c_unshiu_scaffold_id = Regexp.last_match[1]
      c_unshiu_scaffold_id = encode c_unshiu_scaffold_id

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/jbrowse/?data=data%2Fjson%2FC_unshiu" \
      "&loc=#{c_unshiu_scaffold_id}%3A#{best_start}..#{best_end}" \
      "&highlight=#{c_unshiu_scaffold_id}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CMEGANTE%2CCicle_mRNA_by_GMAP%2CPASA%2CSpaln_SwissProt%2CSpaln_TrEMBL%2Crepeat_region%2Crepeat_unit"

      {
        :order => 2,
        :title => 'JBrowse (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def p_trifoliata_gene_jbrowse
      return nil unless id.match(P_trifoliata_Gene_ID_PATTERN)
      p_trifoliata_gene_id = Regexp.last_match[1]
      p_trifoliata_gene_id = encode p_trifoliata_gene_id

      url = "/jbrowse/?data=data%2Fjson%2FP_trifoliata" \
      "&loc=#{p_trifoliata_gene_id}" \
      "&tracks=DNA%2CMEGANTE%2CCicle_mRNA_by_GMAP%2CPASA%2CSpaln_SwissProt%2CSpaln_TrEMBL%2Crepeat_region%2Crepeat_unit"

      {
        :order => 2,
        :title => 'JBrowse (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def p_trifoliata_scaffold_jbrowse
      return nil unless id.match(P_trifoliata_Scaffold_ID_PATTERN)
      p_trifoliata_scaffold_id = Regexp.last_match[1]
      p_trifoliata_scaffold_id = encode p_trifoliata_scaffold_id

      best_start = ""
      best_end = ""
      bscore = hsps.map(&:bit_score).max
      hsps.each do |hsp, value|
        if bscore == hsp.bit_score
          best_start = hsp.sstart
          best_end = hsp.send
        end
      end

      url = "/jbrowse/?data=data%2Fjson%2FP_trifoliata" \
      "&loc=#{p_trifoliata_scaffold_id}%3A#{best_start}..#{best_end}" \
      "&highlight=#{p_trifoliata_scaffold_id}%3A#{best_start}..#{best_end}" \
      "&tracks=DNA%2CMEGANTE%2CCicle_mRNA_by_GMAP%2CPASA%2CSpaln_SwissProt%2CSpaln_TrEMBL%2Crepeat_region%2Crepeat_unit"

      {
        :order => 2,
        :title => 'JBrowse (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def c_clementina_phytozome
      return nil unless id.match(C_clementina_ID_PATTERN)
      c_clementina_gene_id = Regexp.last_match[2]
      c_clementina_gene_id = encode c_clementina_gene_id

      url = "https://phytozome-next.jgi.doe.gov/report/transcript/Cclementina_v1_0/#{c_clementina_gene_id}"
      {
        :order => 2,
        :title => 'Phytozome',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def c_sinensis_hzau_gbrowse
      # Execute "return nil" until the link destination is decided. (2021-11-11)
      return nil
      return nil unless id.match(C_sinensis_ID_PATTERN)
      c_sinensis_gene_id = Regexp.last_match[2]
      c_sinensis_gene_id = encode c_sinensis_gene_id

      url = "http://citrus.hzau.edu.cn/cgi-bin/gb2/gbrowse/orange/?name=#{c_sinensis_gene_id}"
      {
        :order => 2,
        :title => 'GBrowse at HZAU',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def cunphki_gene_jbrowse2
      return nil unless id.match(CUNphKi_ID_PATTERN)
      cunphki_gene_id = Regexp.last_match[1]
      cunphki_gene_id = encode cunphki_gene_id

      url = "/migd2/jbrowse2/?config=data%2Fcf_CUNphKi_r2.0.json&loc=#{cunphki_gene_id}&assembly=CUNphKi_r2.0&tracks=CUNphKi_r2.0-ReferenceSequenceTrack%2CCUNphKi_r2.0.all.wAnnot%2CCUNphKi_r2.0.primaryTranscript&tracklist=true"
      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def cunphku_gene_jbrowse2
      return nil unless id.match(CUNphKu_ID_PATTERN)
      cunphku_gene_id = Regexp.last_match[1]
      cunphku_gene_id = encode cunphku_gene_id

      url = "/migd2/jbrowse2/?config=data%2Fcf_CUNphKu_r2.0.json&loc=#{cunphku_gene_id}&assembly=CUNphKu_r2.0&tracks=CUNphKu_r2.0-ReferenceSequenceTrack%2CCUNphKu_r2.0.all.wAnnot%2CCUNphKu_r2.0.primaryTranscript&tracklist=true"
      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def ckihap1_gene_jbrowse2
      return nil unless id.match(CKIhap1_ID_PATTERN)
      ckihap1_gene_id = Regexp.last_match[1]
      ckihap1_gene_id = encode ckihap1_gene_id

      url = "/migd2/jbrowse2/?config=data%2Fcf_CKIhap1_r2.0.json&loc=#{ckihap1_gene_id}&assembly=CKIhap1_r2.0&tracks=CKIhap1_r2.0-ReferenceSequenceTrack%2CCKIhap1_r2.0.all.wAnnot%2CCKIhap1_r2.0.primaryTranscript&tracklist=true"
      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def ckihap2_gene_jbrowse2
      return nil unless id.match(CKIhap2_ID_PATTERN)
      ckihap2_gene_id = Regexp.last_match[1]
      ckihap2_gene_id = encode ckihap2_gene_id

      url = "/migd2/jbrowse2/?config=data%2Fcf_CKIhap2_r2.0.json&loc=#{ckihap2_gene_id}&assembly=CKIhap2_r2.0&tracks=CKIhap2_r2.0-ReferenceSequenceTrack%2CCKIhap2_r2.0.all.wAnnot%2CCKIhap2_r2.0.primaryTranscript&tracklist=true"
      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def ckuhap1_gene_jbrowse2
      return nil unless id.match(CKUhap1_ID_PATTERN)
      ckuhap1_gene_id = Regexp.last_match[1]
      ckuhap1_gene_id = encode ckuhap1_gene_id

      url = "/migd2/jbrowse2/?config=data%2Fcf_CKUhap1_r2.0.json&loc=#{ckuhap1_gene_id}&assembly=CKUhap1_r2.0&tracks=CKUhap1_r2.0-ReferenceSequenceTrack%2CCKUhap1_r2.0.all.wAnnot%2CCKUhap1_r2.0.primaryTranscript&tracklist=true"
      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def ckuhap2_gene_jbrowse2
      return nil unless id.match(CKUhap2_ID_PATTERN)
      ckuhap2_gene_id = Regexp.last_match[1]
      ckuhap2_gene_id = encode ckuhap2_gene_id

      url = "/migd2/jbrowse2/?config=data%2Fcf_CKUhap2_r2.0.json&loc=#{ckuhap2_gene_id}&assembly=CKUhap2_r2.0&tracks=CKUhap2_r2.0-ReferenceSequenceTrack%2CCKUhap2_r2.0.all.wAnnot%2CCKUhap2_r2.0.primaryTranscript&tracklist=true"
      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def cunphki_chr_jbrowse2
      return nil unless id.match(CUNphKi_CHR_PATTERN)
      cunphki_chr = Regexp.last_match[1]
      cunphki_chr = encode cunphki_chr

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

      url = "/migd2/jbrowse2/?config=data%2Fcf_CUNphKi_r2.0.json&loc=#{cunphki_chr}%3A#{best_start}..#{best_end}&highlight=#{cunphki_chr}%3A#{best_start}..#{best_end}&assembly=CUNphKi_r2.0&tracks=CUNphKi_r2.0-ReferenceSequenceTrack%2CCUNphKi_r2.0.all.wAnnot%2CCUNphKi_r2.0.primaryTranscript&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def cunphku_chr_jbrowse2
      return nil unless id.match(CUNphKu_CHR_PATTERN)
      cunphku_chr = Regexp.last_match[1]
      cunphku_chr = encode cunphku_chr

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

      url = "/migd2/jbrowse2/?config=data%2Fcf_CUNphKu_r2.0.json&loc=#{cunphku_chr}%3A#{best_start}..#{best_end}&highlight=#{cunphku_chr}%3A#{best_start}..#{best_end}&assembly=CUNphKu_r2.0&tracks=CUNphKu_r2.0-ReferenceSequenceTrack%2CCUNphKu_r2.0.all.wAnnot%2CCUNphKu_r2.0.primaryTranscript&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def ckihap1_chr_jbrowse2
      return nil unless id.match(CKIhap1_CHR_PATTERN)
      ckihap1_chr = Regexp.last_match[1]
      ckihap1_chr = encode ckihap1_chr

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

      url = "/migd2/jbrowse2/?config=data%2Fcf_CKIhap1_r2.0.json&loc=#{ckihap1_chr}%3A#{best_start}..#{best_end}&highlight=#{ckihap1_chr}%3A#{best_start}..#{best_end}&assembly=CKIhap1_r2.0&tracks=CKIhap1_r2.0-ReferenceSequenceTrack%2CCKIhap1_r2.0.all.wAnnot%2CCKIhap1_r2.0.primaryTranscript&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def ckihap2_chr_jbrowse2
      return nil unless id.match(CKIhap2_CHR_PATTERN)
      ckihap2_chr = Regexp.last_match[1]
      ckihap2_chr = encode ckihap2_chr

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

      url = "/migd2/jbrowse2/?config=data%2Fcf_CKIhap2_r2.0.json&loc=#{ckihap2_chr}%3A#{best_start}..#{best_end}&highlight=#{ckihap2_chr}%3A#{best_start}..#{best_end}&assembly=CKIhap2_r2.0&tracks=CKIhap2_r2.0-ReferenceSequenceTrack%2CCKIhap2_r2.0.all.wAnnot%2CCKIhap2_r2.0.primaryTranscript&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def ckuhap1_chr_jbrowse2
      return nil unless id.match(CKUhap1_CHR_PATTERN)
      ckuhap1_chr = Regexp.last_match[1]
      ckuhap1_chr = encode ckuhap1_chr

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

      url = "/migd2/jbrowse2/?config=data%2Fcf_CKUhap1_r2.0.json&loc=#{ckuhap1_chr}%3A#{best_start}..#{best_end}&highlight=#{ckuhap1_chr}%3A#{best_start}..#{best_end}&assembly=CKUhap1_r2.0&tracks=CKUhap1_r2.0-ReferenceSequenceTrack%2CCKUhap1_r2.0.all.wAnnot%2CCKUhap1_r2.0.primaryTranscript&tracklist=true"

      {
        :order => 2,
        :title => 'JBrowse2 (best hit)',
        :url   => url,
        :icon  => 'fa-external-link'
      }
    end

    def ckuhap2_chr_jbrowse2
      return nil unless id.match(CKUhap2_CHR_PATTERN)
      ckuhap2_chr = Regexp.last_match[1]
      ckuhap2_chr = encode ckuhap2_chr

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

      url = "/migd2/jbrowse2/?config=data%2Fcf_CKUhap2_r2.0.json&loc=#{ckuhap2_chr}%3A#{best_start}..#{best_end}&highlight=#{ckuhap2_chr}%3A#{best_start}..#{best_end}&assembly=CKUhap2_r2.0&tracks=CKUhap2_r2.0-ReferenceSequenceTrack%2CCKUhap2_r2.0.all.wAnnot%2CCKUhap2_r2.0.primaryTranscript&tracklist=true"

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
