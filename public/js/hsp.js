import React, { useState, createRef, useEffect } from "react";
import useDetectPrint from "react-detect-print";
import _ from "underscore";

import Utils from "./utils";
import * as Helpers from "./visualisation_helpers";

const JBrowseDBs = {
  main: {
    path: "",
    assembly: "genome",
    jbrowse1Data: "data%2Firgsp1",
    jbrowse2Config: "data%2Firgsp1.json",
    tracks: ["irgsp1_rep_transcript.sorted.gff"]
  },
  ModelCrops: {
    path: "/ModelCrops",
    assemblies: {
      OsNPB: { assembly: "Rice", tracks: ["Rice_0", "Rice_1", "Rice_2", "Rice_3"] },
      Ta: { assembly: "Wheat", tracks: ["Wheat"] },
      Hv: { assembly: "Barley", tracks: ["Barley"] },
      Zm: { assembly: "Corn", tracks: ["Corn"] },
      At: { assembly: "Arabidopsis", tracks: ["Arabidopsis"] },
      GmWm82: { assembly: "Soybean", tracks: ["Soybean"] },
      CqJ100: { assembly: "Cquinoa", tracks: ["Cquinoa"] },
      Vm: { assembly: "VignaMarina", tracks: ["VignaMarina"] }
    }
  },
  genomedb_rapdb: {
    path: "/genomedb_rapdb",
    assemblies: {
      OsNPB: { assembly: "Nipponbare", tracks: ["Nipponbare_0", "Nipponbare_1", "Nipponbare_2", "Nipponbare_3"] },
      OsKSH: { assembly: "Koshihikari", tracks: ["Koshihikari_0", "Koshihikari_1", "Koshihikari_2"] },
      OsTKN: { assembly: "Takanari", tracks: ["Takanari_0", "Takanari_1", "Takanari_2"] },
      OsH193: { assembly: "Hokuriku_193", tracks: ["Hokuriku_193_0", "Hokuriku_193_1", "Hokuriku_193_2"] }
    }
  },
  genomedb_ms: {
    path: "/genomedb_ms",
    assemblies: {
      OsNPB: { assembly: "NPB", tracks: ["NPB_0", "NPB_1", "NPB_2", "NPB_3"] },
      OsKP: { assembly: "KP", tracks: ["KP_0", "KP_1", "KP_2"] },
      OsKSL: { assembly: "Kasalath", tracks: ["Kasalath_0", "Kasalath_1", "Kasalath_2"] },
      OrIRGC104814: { assembly: "IRGC104814", tracks: ["IRGC104814_0", "IRGC104814_1", "IRGC104814_2"] },
      OrJP223922: { assembly: "JP223922", tracks: ["JP223922_0", "JP223922_1", "JP223922_2"] },
      OrJP226069: { assembly: "JP226069", tracks: ["JP226069_0", "JP226069_1", "JP226069_2"] },
      OsIR64: { assembly: "IR64", tracks: ["IR64_0", "IR64_1", "IR64_2"] },
      ObIRGC101243: { assembly: "IRGC101243", tracks: ["IRGC101243_0", "IRGC101243_1", "IRGC101243_2"] },
      OmIRGC104086: { assembly: "IRGC104086", tracks: ["IRGC104086_0", "IRGC104086_1", "IRGC104086_2"] }
    }
  }
};

const MODEL_CROPS_ID_PREFIXES = ["GmWm82", "CqJ100", "OsNPB", "Ta", "Hv", "Zm", "At", "Vm"];

const getInstanceGroup = () => {
  const path = window.location.pathname;
  if (path.includes("/ModelCrops/")) return "ModelCrops";
  if (path.includes("/genomedb_rapdb/")) return "genomedb_rapdb";
  if (path.includes("/genomedb_ms/")) return "genomedb_ms";
  return "main";
};

const getGenomedbAssembly = (instanceGroup, id) => {
  if (instanceGroup === "main") return JBrowseDBs.main;

  const { assemblies } = JBrowseDBs[instanceGroup];
  const hitId = String(id);
  const prefix = instanceGroup === "ModelCrops"
    ? MODEL_CROPS_ID_PREFIXES.find((item) => hitId.startsWith(item)) || "OsNPB"
    : hitId.split("_")[0];
  return assemblies[prefix];
};

/**
 * Alignment viewer.
 */
// export default class HSP extends React.Component {
export default function HSP(props) {
  const hsp = props.hsp;
  const hspRef = createRef();
  const printing = useDetectPrint();
  const [chars, setChars] = useState(0)
  const [width, setWidth] = useState(window.innerWidth);

  const domID = () => {
    const { query, hit, hsp } = props;
    return `Query_${query.number}_hit_${hit.number}_${hsp.number}`;
  }

  const hitDOM_ID = () => {
    return "Query_" + props.query.number + "_hit_" + props.hit.number;
  }

  useEffect(() => {
    // Attach a debounced listener to handle window resize events 
    // Updates the width state with the current window width, throttled to run at most once every 125ms
    const handleResize = _.debounce(() => setWidth(window.innerWidth), 125);
    window.addEventListener("resize", handleResize);

    // TODO: print handler
    draw();
  }, [])

  useEffect(() => {
    draw(printing);
  }, [printing, width])
  
  const draw = (printing = false) => {
    const charWidth = props.getCharacterWidth();
    const containerWidth = printing ? 900 : $(hspRef.current).width();
    setChars(Math.floor((containerWidth - 4) / charWidth))
  }

  /**
   * Returns an array of span elements or plain strings (React automatically
   * adds span tag around strings). This array is passed as it is to JSX to be
   * rendered just above the pairwise alignment (see render method).
   *
   * We cannot return a string from this method otherwise we wouldn't be able
   * to use JSX elements to format text (like, superscript).
   */
  const hspStats = () => {
    // An array to hold text or span elements that make up the line.
    let line = [];

    // Bit score and total score.
    line.push(
      `Score: ${Utils.inTwoDecimal(hsp.bit_score)} (${hsp.score}), `
    );

    // E value
    line.push("E value: ");
    line.push(Utils.inExponential(hsp.evalue));
    line.push(", ");

    // Identity
    line.push([
      `Identity: ${Utils.inFraction(
        hsp.identity,
        hsp.length
      )} (${Utils.inPercentage(hsp.identity, hsp.length)}), `,
    ]);

    // Positives (for protein alignment).
    if (
      props.algorithm === "blastp" ||
      props.algorithm === "blastx" ||
      props.algorithm === "tblastn" ||
      props.algorithm === "tblastx"
    ) {
      line.push(
        `Positives: ${Utils.inFraction(
          hsp.positives,
          hsp.length
        )} (${Utils.inPercentage(hsp.positives, hsp.length)}), `
      );
    }

    // Gaps
    line.push(
      `Gaps: ${Utils.inFraction(
        hsp.gaps,
        hsp.length
      )} (${Utils.inPercentage(hsp.gaps, hsp.length)})`
    );

    // Query coverage
    //line.push(`Query coverage: ${this.hsp.qcovhsp}%, `)

    switch (props.algorithm) {
      case "tblastx":
        line.push(
          `, Frame: ${Utils.inFraction(hsp.qframe, hsp.sframe)}`
        );
        break;
      case "blastn":
        line.push(
          `, Strand: ${hsp.qframe > 0 ? "+" : "-"} / ${
            hsp.sframe > 0 ? "+" : "-"
          }`
        );
        break;
      case "blastx":
        line.push(`, Query Frame: ${hsp.qframe}`);
        break;
      case "tblastn":
        line.push(`, Hit Frame: ${hsp.sframe}`);
        break;
    }

    return line;
  }


  // Width of the coordinate part of hsp lines. Essentially the length of
  // the largest coordinate.
  const hspLinesWidth = () => {
    return _.max(
      _.map(
        [hsp.qstart, hsp.qend, hsp.sstart, hsp.send],
        (n) => {
          return n.toString().length;
        }
      )
    );
  }

  /**
   * Returns array of pre tags containing the three query, middle, and subject
   * lines that together comprise one 'rendered line' of HSP.
   */
  const hspLines = () => {
    // Space reserved for showing coordinates
    const width = hspLinesWidth();

    // Number of residues we can draw per line is the total number of
    // characters we can have in a line minus space required to show left
    // and right coordinates minus 10 characters reserved for displaying
    // the words Query, Subject and three blank spaces per line.
    const adjustedLineWidth = chars - 2 * width - 10;

    // Number of lines of pairwise-alignment (i.e., each line consists of 3
    // lines). We draw as many pre tags.
    const lines = Math.ceil(hsp.length / adjustedLineWidth);

    let pp = [];
    let nqseq = getNqseq();
    let nsseq = getNsseq();
    for (let i = 1; i <= lines; i++) {
      let seq_start_index = adjustedLineWidth * (i - 1);
      let seq_stop_index = seq_start_index + adjustedLineWidth;

      let lqstart = nqseq;
      let lqseq = hsp.qseq.slice(seq_start_index, seq_stop_index);
      let lqend =
        nqseq +
        (lqseq.length - lqseq.split("-").length) *
          qframe_unit() *
          qframe_sign();
      nqseq = lqend + qframe_unit() * qframe_sign();

      let lmseq = hsp.midline.slice(seq_start_index, seq_stop_index);

      let lsstart = nsseq;
      let lsseq = hsp.sseq.slice(seq_start_index, seq_stop_index);
      let lsend =
        nsseq +
        (lsseq.length - lsseq.split("-").length) *
          sframe_unit() *
          sframe_sign();
      nsseq = lsend + sframe_unit() * sframe_sign();

      pp.push(
        <pre key={hsp.number + "," + i} className="pre-item m-0 p-0 rounded-none border-0 bg-inherit whitespace-pre-wrap break-keep mt-1 tracking-wider">
          <span className="text-gray-500">
            {`Query   ${formatCoords(lqstart, width)} `}
          </span>
          <span>{lqseq}</span>
          <span className="text-gray-500">{` ${lqend}`}</span>
          <br />
          <span className="text-gray-500">
            {`${formatCoords("", width + 8)} `}
          </span>
          <span>{lmseq}</span>
          <br />
          <span className="text-gray-500">
            {`Subject ${formatCoords(lsstart, width)} `}
          </span>
          <span>{lsseq}</span>
          <span className="text-gray-500">{` ${lsend}`}</span>
          <br />
        </pre>
      );
    }

    return pp;
  }


  // Alignment start coordinate for query sequence.
  //
  // This will be qstart or qend depending on the direction in which the
  // (translated) query sequence aligned.
  const getNqseq = () => {
    switch (props.algorithm) {
      case "blastp":
      case "blastx":
      case "tblastn":
      case "tblastx":
        return hsp.qframe >= 0 ? hsp.qstart : hsp.qend;
      case "blastn":
        // BLASTN is a bit weird in that, no matter which direction the query
        // sequence aligned in, qstart is taken as alignment start coordinate
        // for query.
        return hsp.qstart;
    }
  }

  // Alignment start coordinate for subject sequence.
  //
  // This will be sstart or send depending on the direction in which the
  // (translated) subject sequence aligned.
  const getNsseq = () => {
    switch (props.algorithm) {
      case "blastp":
      case "blastx":
      case "tblastn":
      case "tblastx":
        return hsp.sframe >= 0 ? hsp.sstart : hsp.send;
      case "blastn":
        // BLASTN is a bit weird in that, no matter which direction the
        // subject sequence aligned in, sstart is taken as alignment
        // start coordinate for subject.
        return hsp.sstart;
    }
  }

  // Jump in query coordinate.
  //
  // Roughly,
  //
  //   qend = qstart + n * qframe_unit
  //
  // This will be 1 or 3 depending on whether the query sequence was
  // translated or not.
  const qframe_unit = () => {
    switch (props.algorithm) {
      case "blastp":
      case "blastn":
      case "tblastn":
        return 1;
      case "blastx":
      // _Translated_ nucleotide query against protein database.
      case "tblastx":
        // _Translated_ nucleotide query against translated
        // nucleotide database.
        return 3;
    }
  }

  // Jump in subject coordinate.
  //
  // Roughly,
  //
  //   send = sstart + n * sframe_unit
  //
  // This will be 1 or 3 depending on whether the subject sequence was
  // translated or not.
  const sframe_unit = () => {
    switch (props.algorithm) {
      case "blastp":
      case "blastx":
      case "blastn":
        return 1;
      case "tblastn":
        // Protein query against _translated_ nucleotide database.
        return 3;
      case "tblastx":
        // Translated nucleotide query against _translated_
        // nucleotide database.
        return 3;
    }
  }

  // If we should add or subtract qframe_unit from qstart to arrive at qend.
  //
  // Roughly,
  //
  //   qend = qstart + (qframe_sign) * n * qframe_unit
  //
  // This will be +1 or -1, depending on the direction in which the
  // (translated) query sequence aligned.
  const qframe_sign = () => {
    return hsp.qframe >= 0 ? 1 : -1;
  }

  // If we should add or subtract sframe_unit from sstart to arrive at send.
  //
  // Roughly,
  //
  //   send = sstart + (sframe_sign) * n * sframe_unit
  //
  // This will be +1 or -1, depending on the direction in which the
  // (translated) subject sequence aligned.
  const sframe_sign = () => {
    return hsp.sframe >= 0 ? 1 : -1;
  }

  /**
   * Pad given coord with ' ' till its length == width. Returns undefined if
   * width is not supplied.
   */
  const formatCoords = (coord, width) => {
    if (width) {
      let padding = width - coord.toString().length;
      return Array(padding + 1)
        .join(" ")
        .concat([coord]);
    }
  }

  const spanCoords = (text) => {
    return <span className="text-gray-700">{text}</span>;
  }

  const jbrowseLink = () => {
    if (
      props.algorithm === "blastn"
    ) {
      const hitLen = Math.abs(hsp.send - hsp.sstart);
      const viewStart = Math.min(hsp.sstart, hsp.send) - Math.floor(hitLen * 0.1);
      const viewEnd = Math.max(hsp.sstart, hsp.send) + Math.floor(hitLen * 0.1);
      const strand = (hsp.send - hsp.sstart) < 0 ? "-1" : "1";

      const myFeatures = encodeURIComponent(JSON.stringify([
        {
          seq_id: props.hit.id,
          start: Math.min(hsp.sstart, hsp.send) - 1,
          end: Math.max(hsp.sstart, hsp.send),
          strand: strand,
          name: `HSP#${hsp.number}`
        }
      ]));

      const myTrack = encodeURIComponent(JSON.stringify([
        {
          label: "BLAST",
          type: "JBrowse/View/Track/CanvasFeatures",
          store: "url",
          style: {
            color: "aqua"
          }
        }
      ]));

      const instanceGroup = getInstanceGroup();
      const db = JBrowseDBs[instanceGroup];
      const assembly = getGenomedbAssembly(instanceGroup, props.hit.id);
      if (!assembly) return null;
      const baseUrl = instanceGroup === "main"
        ? `${db.path}/jbrowse/?data=${db.jbrowse1Data}`
        : `${db.path}/jbrowse/?data=${assembly.assembly}&tracks=DNA%2C${assembly.tracks.join("%2C")}`;
      const jbrowse1Url =
        `${baseUrl}` +
        `&loc=${props.hit.id}%3A${viewStart}..${viewEnd}` +
        `&addFeatures=${myFeatures}` +
        `&addTracks=${myTrack}`;
      return (
        <a target="_blank" rel="noopener noreferrer" href={jbrowse1Url} className="btn-link text-sm font-normal text-seqblue hover:text-seqorange ml-3 print:hidden">
          <i className="fa fa-external-link" /> JBrowse1
        </a>
      );
    }
    return null;
  }

  const jbrowse2Link = () => {
    if (
      props.algorithm === "blastn"
    ) {
      const hitLen = Math.abs(hsp.send - hsp.sstart);
      const viewStart = Math.min(hsp.sstart, hsp.send) - Math.floor(hitLen * 0.1);
      const viewEnd = Math.max(hsp.sstart, hsp.send) + Math.floor(hitLen * 0.1);
      const instanceGroup = getInstanceGroup();
      const db = JBrowseDBs[instanceGroup];
      const assembly = getGenomedbAssembly(instanceGroup, props.hit.id);
      if (!assembly) return null;
      const trackId = `blast_hit_${props.hit.id}_${hsp.sstart}`;
      const customTrack = [
        {
          type: "FeatureTrack",
          trackId: trackId,
          name: `BLAST Hit: ${props.hit.id}`,
          assemblyNames: [assembly.assembly],
          adapter: {
            type: "FromConfigAdapter",
            features: [
              {
                uniqueId: `${trackId}_f1`,
                refName: props.hit.id,
                start: Math.min(hsp.sstart, hsp.send) - 1,
                end: Math.max(hsp.sstart, hsp.send), 
                type: "match",
                name: `HSP#${hsp.number}`
              },
            ]
          },
          displays: [
            {
              type: "LinearBasicDisplay",
              renderer: {
                type: "SvgFeatureRenderer",
                color1: "aqua"
              }
            }
          ]
        }
      ];

      const baseUrl = instanceGroup === "main"
        ? `${db.path}/jbrowse2/?config=${db.jbrowse2Config}&assembly=${assembly.assembly}`
        : `${db.path}/jbrowse2/?config=data%2Fcf_${assembly.assembly}.json&assembly=${assembly.assembly}`;
      const jbrowse2Url =
        `${baseUrl}` +
        `&loc=${props.hit.id}:${viewStart}..${viewEnd}` +
        `&tracks=${trackId},${assembly.tracks[0]}` +
        `&tracklist=true` +
        `&sessionTracks=${encodeURIComponent(JSON.stringify(customTrack))}`;
      return (
        <a target="_blank" rel="noopener noreferrer" href={jbrowse2Url} className="btn-link text-sm font-normal text-seqblue hover:text-seqorange ml-3 print:hidden">
          <i className="fa fa-external-link" /> JBrowse2
        </a>
      );
    }
    return null;
  }

  return (
    <div
      className="hsp pt-px pb-5 border-l-2 border-transparent pl-1 -ml-1"
      id={domID()}
      ref={hspRef}
      data-parent-hit={hitDOM_ID()}
    >
      <p className="m-0 p-0 rounded-none border-0 bg-inherit whitespace-pre-wrap break-keep text-sm text-neutral-500 font-semibold tracking-wide">
        {props.showHSPNumbers &&
          `${Helpers.toLetters(hsp.number)}. `}
        {hspStats().map((s, i) => (
          <span key={i}>{s}</span>
        ))}
        {jbrowseLink()} |
        {jbrowse2Link()}
      </p>
      {hspLines()}
    </div>
  );
}

// Redraw if window resized.
// $(window).resize(
//   _.debounce(function () {
//     _.each(HSPComponents, (comp) => {
//       comp.draw();
//     });
//   }, 100)
// );
