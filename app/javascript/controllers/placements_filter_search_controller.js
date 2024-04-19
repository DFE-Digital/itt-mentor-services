import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="placements-filter-search"
export default class extends Controller {
  static targets = [ "phaseOption", "schoolOption", "subjectOption" ]

  connect() {
    this.filterOptions();
  }

  filterOptions() {
    const allPhases = this.phaseOptionTargets.map(phase => phase.value);
    const checkedPhases = this.phaseOptionTargets
      .filter(phase => phase.checked)
      .map(phase => phase.value);

    const primarySchools = this.schoolOptionTargets
      .filter(school => school.dataset.phase === "Primary");

    const secondarySchools = this.schoolOptionTargets
      .filter(school => school.dataset.phase === "Secondary");

    const primarySubjects = this.subjectOptionTargets
      .filter(subject => subject.dataset.subjectArea === "Primary");

    const secondarySubjects = this.subjectOptionTargets
      .filter(subject => subject.dataset.subjectArea === "Secondary");

    if (checkedPhases.length === 0) {
      this.toggleOptions(primarySchools, "flex");
      this.toggleOptions(secondarySchools, "flex");
      this.toggleOptions(primarySubjects, "flex");
      this.toggleOptions(secondarySubjects, "flex");
    } else if (allPhases.length === checkedPhases.length) {
      this.toggleOptions(primarySchools, "flex");
      this.toggleOptions(secondarySchools, "flex");
      this.toggleOptions(primarySubjects, "flex");
      this.toggleOptions(secondarySubjects, "flex");
    } else if (checkedPhases.includes("Primary")) {
      this.toggleOptions(primarySchools, "flex");
      this.toggleOptions(secondarySchools, "none");
      this.toggleOptions(primarySubjects, "flex");
      this.toggleOptions(secondarySubjects, "none");
    } else {
      this.toggleOptions(primarySchools, "none");
      this.toggleOptions(secondarySchools, "flex");
      this.toggleOptions(primarySubjects, "none");
      this.toggleOptions(secondarySubjects, "flex");
    }
  }

  toggleOptions(options, display){
    options.forEach(option => {
      option.parentElement.style.display = display;
    });
  }
}
