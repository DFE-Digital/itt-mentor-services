import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="map"
export default class extends Controller {
  static values = { 
    key: String, mapId: String, baseLongitude: Number, baseLatitude: Number,
  }

  static targets = ["schools", "map"]

  connect() {
    this.activateAPI();
    this.generateMap();
    this.mapTarget.classList.add("active-map");
  }

  activateAPI() {
    (g=>{var h,a,k,p="The Google Maps JavaScript API",c="google",l="importLibrary",q="__ib__",m=document,b=window;b=b[c]||(b[c]={});var d=b.maps||(b.maps={}),r=new Set,e=new URLSearchParams,u=()=>h||(h=new Promise(async(f,n)=>{await (a=m.createElement("script"));e.set("libraries",[...r]+"");for(k in g)e.set(k.replace(/[A-Z]/g,t=>"_"+t[0].toLowerCase()),g[k]);e.set("callback",c+".maps."+q);a.src=`https://maps.${c}apis.com/maps/api/js?`+e;d[q]=f;a.onerror=()=>h=n(Error(p+" could not load."));a.nonce=m.querySelector("script[nonce]")?.nonce||"";m.head.append(a)}));d[l]?console.warn(p+" only loads once. Ignoring:",g):d[l]=(f,...n)=>r.add(f)&&u().then(()=>d[l](f,...n))})({
      key: this.keyValue,
      v: "weekly",
      // Use the 'v' parameter to indicate the version to use (weekly, beta, alpha, etc.).
      // Add other bootstrap parameters as needed, using camel case.
    });
  }

  async generateMap(){
    const { Map } = await google.maps.importLibrary("maps");
    const { AdvancedMarkerElement } = await google.maps.importLibrary("marker");
    const position = {lat: this.baseLatitudeValue, lng: this.baseLongitudeValue};
    const mapDiv = this.mapTarget;
    let zoom = 15;

    if (this.schoolsTargets.length > 1){
      zoom = 10;
    }

    const map = new Map(mapDiv, {
      zoom: zoom,
      center: position,
      mapId: this.mapIdValue,
    });

    Array.from(this.schoolsTargets).forEach(function (school) {
      const markerPosition = {
        lat: Number(school.dataset.markerLatitude), 
        lng: Number(school.dataset.markerLongitude)
      }
      new AdvancedMarkerElement({
        map: map,
        position: markerPosition,
        title: school.dataset.markerTitle,
      });
    });
  }
}
