
import React, { Component } from 'react';
import { bindActionCreators } from 'redux';
import { connect } from 'react-redux';
import { Prompt, Redirect } from 'react-router';
import { Formik, Field, Form } from 'formik';
import { Button, Row, Col, ButtonToolbar, ButtonGroup, DropdownItem, DropdownMenu, DropdownToggle, UncontrolledDropdown, Nav, NavItem, NavLink } from 'reactstrap';
import classNames from 'classnames';
import DocumentTitle from '../../components/custom/DocumentTitle';
import LoadingIcon from 'mdi-react/LoadingIcon';
import CheckIcon from 'mdi-react/CheckIcon';
import DatePicker from '../../components/custom/DatePicker';
import NaviBar from '../../components/custom/NaviBar';
import { default as FileInputFieldV1 } from '../../components/custom/FileInputV1';
import { default as FileInputField } from '../../components/custom/FileInput';
import SignaturePanel from '../../components/custom/SignaturePanel';
import AutoCompleteField from '../../components/custom/AutoCompleteField';
import DropdownField from '../../components/custom/DropdownField';
import ModalDialog from '../../components/custom/ModalDialog';
import { showNotification } from '../../redux/Notification';
import RintagiScreen from '../../components/custom/Screen';
import { registerBlocker, unregisterBlocker } from '../../helpers/navigation'
import { isEmptyId, getAddDtlPath, getAddMstPath, getEditDtlPath, getEditMstPath, getDefaultPath, getNaviPath, decodeEmbeddedFileObjectFromServer } from '../../helpers/utils';
import { toMoney, toInputLocalAmountFormat, toLocalAmountFormat, toLocalDateFormat, toDate, strFormat, formatContent } from '../../helpers/formatter';
import { setTitle, setSpinner } from '../../redux/Global';
import { RememberCurrent, GetCurrent } from '../../redux/Persist';
import { getNaviBar } from './index';
import AdmScreenFilterReduxObj, { ShowMstFilterApplied } from '../../redux/AdmScreenFilter';
import * as AdmScreenFilterService from '../../services/AdmScreenFilterService';
import { getRintagiConfig } from '../../helpers/config';
import Skeleton from 'react-skeleton-loader';
import ControlledPopover from '../../components/custom/ControlledPopover';
import log from '../../helpers/logger';

class DtlRecord extends RintagiScreen {
  constructor(props) {
    super(props);
    this.GetReduxState = () => (this.props.AdmScreenFilter || {});
    this.blocker = null;
    this.titleSet = false;
    this.SystemName = (document.Rintagi || {}).systemName || 'Rintagi';
    this.MstKeyColumnName = 'ScreenFilterId86';
    this.DtlKeyColumnName = 'ScreenFilterHlpId87';
    this.hasChangedContent = false;
    this.confirmUnload = this.confirmUnload.bind(this);
    this.AutoCompleteFilterBy = (option, props) => { return true };
    this.OnModalReturn = this.OnModalReturn.bind(this);
    this.ValidatePage = this.ValidatePage.bind(this);
    this.SavePage = this.SavePage.bind(this);
    this.FieldChange = this.FieldChange.bind(this);
    this.DateChange = this.DateChange.bind(this);
    this.StripEmbeddedBase64Prefix = this.StripEmbeddedBase64Prefix.bind(this);
    this.DropdownChangeV1 = this.DropdownChangeV1.bind(this);
    this.FileUploadChangeV1 = this.FileUploadChangeV1.bind(this);
    this.mediaqueryresponse = this.mediaqueryresponse.bind(this);
    this.mobileView = window.matchMedia('(max-width: 1200px)');

    this.state = {
      filename: '',
      submitting: false,
      Buttons: {},
      ScreenButton: null,
      ModalColor: '',
      ModalTitle: '',
      ModalMsg: '',
      ModalOpen: false,
      ModalSuccess: null,
      isMobile: false
    }
    if (!this.props.suppressLoadPage && this.props.history) {
      RememberCurrent('LastAppUrl', (this.props.history || {}).location, true);
    }

    this.props.setSpinner(true);
  }

  mediaqueryresponse(value) {
    if (value.matches) { // if media query matches
      this.setState({ isMobile: true });
    }
    else {
      this.setState({ isMobile: false });
    }
  }

  CultureId87InputChange() {
    const _this = this; 
    return function (name, v) { 
      const filterBy = ''; 
      _this.props.SearchCultureId87(v, filterBy);
    } 
  }
  /* ReactRule: Detail Record Custom Function */
  /* ReactRule End: Detail Record Custom Function */

  ValidatePage(values) {
    const errors = {};
    const columnLabel = (this.props.AdmScreenFilter || {}).ColumnLabel || {};
    const regex = new RegExp(/^-?(?:\d+|\d{1,3}(?:\d{3})+)(?:(\.|,)\d+)?$/);
    /* standard field validation */
    if (isEmptyId((values.cCultureId87 || {}).value)) { errors.cCultureId87 = (columnLabel.CultureId87 || {}).ErrMessage; }
    if (!values.cFilterName87) { errors.cFilterName87 = (columnLabel.FilterName87 || {}).ErrMessage; }
    return errors;
  }

  SavePage(values, { setSubmitting, setErrors, resetForm, setFieldValue, setValues }) {


    this.setState({ submittedOn: Date.now(), submitting: true, setSubmitting: setSubmitting });
    const ScreenButton = this.state.ScreenButton || {};
    /* ReactRule: Detail Record Save */
    /* ReactRule End: Detail Record Save */

    this.props.SavePage(
      this.props.AdmScreenFilter,
      this.props.AdmScreenFilter.Mst,
      [
        {
          ScreenFilterHlpId87: values.cScreenFilterHlpId87 || null,
          CultureId87: (values.cCultureId87 || {}).value || '',
          FilterName87: values.cFilterName87 || '',
          _mode: ScreenButton.buttonType === 'DelRow' ? 'delete' : (values.cScreenFilterHlpId87 ? 'upd' : 'add'),
        }
      ],
      {
        persist: true,
        keepDtl: ScreenButton.buttonType !== 'NewSaveDtl'
      }
    )
  }

  /* standard screen button actions */
  CopyRow({ mst, dtl, dtlId, useMobileView }) {
    const AdmScreenFilterState = this.props.AdmScreenFilter || {};
    const auxSystemLabels = AdmScreenFilterState.SystemLabel || {};
    return function (evt) {
      evt.preventDefault();
      const currDtlId = dtlId || (dtl || {}).ScreenFilterHlpId87;
      const copyFn = () => {
        if (currDtlId) {
          this.props.AddDtl(mst.ScreenFilterId86, currDtlId);
          if (useMobileView) {
            const naviBar = getNaviBar('MstRecord', mst, {}, this.props.AdmScreenFilter.Label);
            this.props.history.push(getEditDtlPath(getNaviPath(naviBar, 'DtlRecord', '/'), '_'));
          }
          else {
            if (this.props.OnCopy) this.props.OnCopy();
          }
        }
        else {
          this.setState({ ModalOpen: true, ModalColor: 'warning', ModalTitle: auxSystemLabels.UnsavedPageTitle || '', ModalMsg: auxSystemLabels.UnsavedPageMsg || '' });
        }
      }
      if (!this.hasChangedContent) copyFn();
      else this.setState({ ModalOpen: true, ModalSuccess: copyFn, ModalColor: 'warning', ModalTitle: auxSystemLabels.UnsavedPageTitle || '', ModalMsg: auxSystemLabels.UnsavedPageMsg || '' });
    }.bind(this);
  }

  DelDtl({ mst, submitForm, ScreenButton, dtl, dtlId }) {
    const AdmScreenFilterState = this.props.AdmScreenFilter || {};
    const auxSystemLabels = AdmScreenFilterState.SystemLabel || {};
    return function (evt) {
      evt.preventDefault();
      const deleteFn = () => {
        const currDtlId = dtlId || dtl.ScreenFilterHlpId87;
        if (currDtlId) {
          const revisedState = {
            ScreenButton
          }
          this.setState(revisedState);
          submitForm();
        }
      };
      this.setState({ ModalOpen: true, ModalSuccess: deleteFn, ModalColor: 'danger', ModalTitle: auxSystemLabels.WarningTitle || '', ModalMsg: auxSystemLabels.DeletePageMsg || '' });

    }.bind(this);
  }

  SaveCloseDtl({ submitForm, ScreenButton, naviBar, redirectTo, onSuccess }) {
    return function (evt) {
      const revisedState = {
        ScreenButton
      }
      this.setState(revisedState);
      submitForm();
    }.bind(this);
  }

  NewSaveDtl({ submitForm, ScreenButton, naviBar, mstId, dtl, redirectTo }) {
    return function (evt) {
      const revisedState = {
        ScreenButton
      }
      this.setState(revisedState);
      submitForm();
    }.bind(this);
  }

  SaveMst({ submitForm, ScreenButton }) {
    return function (evt) {
      const revisedState = {
        ScreenButton
      }
      this.setState(revisedState);
      submitForm();
    }.bind(this);
  }

  SaveDtl({ submitForm, ScreenButton }) {
    return function (evt) {
      const revisedState = {
        ScreenButton
      }
      this.setState(revisedState);
      submitForm();
    }.bind(this);
  }

  /* end of screen button action */

  /* react related stuff */
  static getDerivedStateFromProps(nextProps, prevState) {
    const nextReduxScreenState = nextProps.AdmScreenFilter || {};
    const buttons = nextReduxScreenState.Buttons || {};
    const revisedButtonDef = super.GetScreenButtonDef(buttons, 'Dtl', prevState);
    const currentKey = nextReduxScreenState.key;
    const waiting = nextReduxScreenState.page_saving || nextReduxScreenState.page_loading;
    let revisedState = {};
    if (revisedButtonDef) revisedState.Buttons = revisedButtonDef;
    if (prevState.submitting && !waiting && nextReduxScreenState.submittedOn > prevState.submittedOn) {
      prevState.setSubmitting(false);
      revisedState.filename = '';
    }

    return revisedState;
  }

  confirmUnload(message, callback) {
    const AdmScreenFilterState = this.props.AdmScreenFilter || {};
    const auxSystemLabels = AdmScreenFilterState.SystemLabel || {};
    const confirm = () => {
      callback(true);
    }
    const cancel = () => {
      callback(false);
    }
    this.setState({ ModalOpen: true, ModalSuccess: confirm, ModalCancel: cancel, ModalColor: 'warning', ModalTitle: auxSystemLabels.UnsavedPageTitle || '', ModalMsg: message });
  }

  setDirtyFlag(dirty) {
    /* this is called during rendering but has side-effect, undesirable but only way to pass formik dirty flag around */
    if (dirty) {
      if (this.blocker) unregisterBlocker(this.blocker);
      this.blocker = this.confirmUnload;
      registerBlocker(this.confirmUnload);
    }
    else {
      if (this.blocker) unregisterBlocker(this.blocker);
      this.blocker = null;
    }
    if (this.props.updateChangedState) this.props.updateChangedState(dirty);
    this.SetCurrentRecordState(dirty);
    return true;
  }

  componentDidMount() {
    this.mediaqueryresponse(this.mobileView);
    this.mobileView.addListener(this.mediaqueryresponse) // attach listener function to listen in on state changes
    const isMobileView = this.state.isMobile;
    const useMobileView = (isMobileView && !(this.props.user || {}).desktopView);
    const suppressLoadPage = this.props.suppressLoadPage;
    if (!suppressLoadPage) {
      const { mstId, dtlId } = { ...this.props.match.params };
      if (!(this.props.AdmScreenFilter || {}).AuthCol || true)
        this.props.LoadPage('Item', { mstId: mstId || '_', dtlId: dtlId || '_' });
    }
    else {
      return;
    }
  }
  componentDidUpdate(prevprops, prevstates) {
    const currReduxScreenState = this.props.AdmScreenFilter || {};

    if (!this.props.suppressLoadPage) {
      if (!currReduxScreenState.page_loading && this.props.global.pageSpinner) {
        const _this = this;
        setTimeout(() => _this.props.setSpinner(false), 500);
      }
    }

    this.SetPageTitle(currReduxScreenState);
    if (prevstates.key !== (currReduxScreenState.EditDtl || {}).key) {
      if ((prevstates.ScreenButton || {}).buttonType === 'SaveCloseDtl') {
        const currMst = (currReduxScreenState.Mst);
        const currDtl = (currReduxScreenState.EditDtl);
        const dtlList = (currReduxScreenState.DtlList || {}).data || [];

        const naviBar = getNaviBar('DtlRecord', currMst, currDtl, currReduxScreenState.Label);
        const dtlListPath = getDefaultPath(getNaviPath(naviBar, 'DtlList', '/'));

        this.props.history.push(dtlListPath);
      }
    }

  }

  componentWillUnmount() {
    if (this.blocker) {
      unregisterBlocker(this.blocker);
      this.blocker = null;
    }
    this.mobileView.removeListener(this.mediaqueryresponse);
  }

  handleFocus = (event) => {
    event.target.setSelectionRange(0, event.target.value.length);
  }

  render() {
    const AdmScreenFilterState = this.props.AdmScreenFilter || {};
    if (AdmScreenFilterState.access_denied) {
      return <Redirect to='/error' />;
    }
    const screenHlp = AdmScreenFilterState.ScreenHlp;

    // Labels
    const siteTitle = (this.props.global || {}).pageTitle || '';
    const DetailRecTitle = ((screenHlp || {}).DetailRecTitle || '');
    const DetailRecSubtitle = ((screenHlp || {}).DetailRecSubtitle || '');
    const NoMasterMsg = ((screenHlp || {}).NoMasterMsg || '');

    const selectList = AdmScreenFilterReduxObj.SearchListToSelectList(AdmScreenFilterState);
    const selectedMst = (selectList || []).filter(v => v.isSelected)[0] || {};
    const screenButtons = AdmScreenFilterReduxObj.GetScreenButtons(AdmScreenFilterState) || {};
    const auxLabels = AdmScreenFilterState.Label || {};
    const auxSystemLabels = AdmScreenFilterState.SystemLabel || {};
    const columnLabel = AdmScreenFilterState.ColumnLabel || {};
    const currMst = AdmScreenFilterState.Mst;
    const currDtl = AdmScreenFilterState.EditDtl;
    const naviBar = getNaviBar('DtlRecord', currMst, currDtl, screenButtons);
    const authCol = this.GetAuthCol(AdmScreenFilterState);
    const authRow = (AdmScreenFilterState.AuthRow || [])[0] || {};
    const { dropdownMenuButtonList, bottomButtonList, hasDropdownMenuButton, hasBottomButton, hasRowButton } = this.state.Buttons;
    const hasActableButtons = hasBottomButton || hasRowButton || hasDropdownMenuButton;

    const isMobileView = this.state.isMobile;
    const useMobileView = (isMobileView && !(this.props.user || {}).desktopView);
    const fileFileUploadOptions = {
      CancelFileButton: 'Cancel',
      DeleteFileButton: 'Delete',
      MaxImageSize: {
        Width: 1024,
        Height: 768,
      },
      MinImageSize: {
        Width: 40,
        Height: 40,
      },
      maxSize: 5 * 1024 * 1024,
    }
    const CultureId87List = AdmScreenFilterReduxObj.ScreenDdlSelectors.CultureId87(AdmScreenFilterState);
    const CultureId87 = currDtl.CultureId87;
    const FilterName87 = currDtl.FilterName87;
    /* ReactRule: Detail Record Render */
    /* ReactRule End: Detail Record Render */

    return (
      <DocumentTitle title={siteTitle}>
        <div>
          <ModalDialog color={this.state.ModalColor} title={this.state.ModalTitle} onChange={this.OnModalReturn} ModalOpen={this.state.ModalOpen} message={this.state.ModalMsg} />
          <div className='account'>
            <div className='account__wrapper account-col'>
              <div className='account__card shadow-box rad-4'>
                {/* {!useMobileView && this.constructor.ShowSpinner(this.props.AdmScreenFilter) && <div className='panel__refresh'><LoadingIcon /></div>} */}
                {useMobileView && <div className='tabs tabs--justify tabs--bordered-bottom'>
                  <div className='tabs__wrap'>
                    <NaviBar history={this.props.history} navi={naviBar} />
                  </div>
                </div>}
                <p className='project-title-mobile mb-10'>{siteTitle.substring(0, document.title.indexOf('-') - 1)}</p>
                <Formik
                  initialValues={{
                    cScreenFilterHlpId87: currDtl.ScreenFilterHlpId87 || '',
                    cCultureId87: CultureId87List.filter(obj => { return obj.key === currDtl.CultureId87 })[0],
                    cFilterName87: formatContent(currDtl.FilterName87 || '', 'TextBox'),
                  }}
                  validate={this.ValidatePage}
                  onSubmit={this.SavePage}
                  key={currDtl.key}
                  render={({
                    values,
                    errors,
                    touched,
                    isSubmitting,
                    dirty,
                    setFieldValue,
                    setFieldTouched,
                    handleReset,
                    handleChange,
                    submitForm,
                    handleFocus
                  }) => (
                      <div>
                        {this.setDirtyFlag(dirty) &&
                          <Prompt
                            when={dirty}
                            message={auxSystemLabels.UnsavedPageMsg || ''}
                          />
                        }
                        <div className='account__head'>
                          <Row>
                            <Col xs={9}>
                              <h3 className='account__title'>{DetailRecTitle}</h3>
                              <h4 className='account__subhead subhead'>{DetailRecSubtitle}</h4>
                            </Col>
                            <Col xs={3}>
                              <ButtonToolbar className='f-right'>
                                <UncontrolledDropdown>
                                  <ButtonGroup className='btn-group--icons'>
                                    <i className={dirty ? 'fa fa-exclamation exclamation-icon' : ''}></i>
                                    {
                                      dropdownMenuButtonList.filter(v => !v.expose && !this.ActionSuppressed(authRow, v.buttonType, (currMst || {}).ScreenFilterId86, currDtl.ScreenFilterHlpId87)).length > 0 &&
                                      <DropdownToggle className='mw-50' outline>
                                        <i className='fa fa-ellipsis-h icon-holder'></i>
                                        {!useMobileView && <p className='action-menu-label'>{(screenButtons.More || {}).label}</p>}
                                      </DropdownToggle>
                                    }
                                  </ButtonGroup>
                                  {
                                    dropdownMenuButtonList.filter(v => !v.expose).length > 0 &&
                                    <DropdownMenu right className={`dropdown__menu dropdown-options`}>
                                      {
                                        dropdownMenuButtonList.filter(v => !v.expose).map(v => {
                                          if (this.ActionSuppressed(authRow, v.buttonType, (currMst || {}).ScreenFilterId86, currDtl.ScreenFilterHlpId87)) return null;
                                          return (
                                            <DropdownItem key={v.tid} onClick={this.ScreenButtonAction[v.buttonType]({ naviBar, ScreenButton: v, submitForm, mst: currMst, dtl: currDtl, useMobileView })} className={`${v.className}`}><i className={`${v.iconClassName} mr-10`}></i>{v.label}</DropdownItem>)
                                        })
                                      }
                                    </DropdownMenu>
                                  }
                                </UncontrolledDropdown>
                              </ButtonToolbar>
                            </Col>
                          </Row>
                        </div>
                        <Form className='form'> {/* this line equals to <form className='form' onSubmit={handleSubmit} */}
                          <div className='form__form-group'>
                            <div className='form__form-group-narrow'>
                              <div className='form__form-group-field'>
                                <span className='radio-btn radio-btn--button btn--button-header h-20 no-pointer'>
                                  <span className='radio-btn__label color-blue fw-700 f-14'>{selectedMst.label || NoMasterMsg}</span>
                                  <span className='radio-btn__label__right color-blue fw-700 f-14'><span className='mr-5'>{selectedMst.labelR || NoMasterMsg}</span>
                                  </span>
                                </span>
                              </div>
                              <div className='form__form-group-field'>
                                <span className='radio-btn radio-btn--button btn--button-header h-20 no-pointer'>
                                  <span className='radio-btn__label color-blue fw-700 f-14'>{selectedMst.detail || NoMasterMsg}</span>
                                  <span className='radio-btn__label__right color-blue fw-700 f-14'><span className='mr-5'>{selectedMst.detailR || NoMasterMsg}</span>
                                  </span>
                                </span>
                              </div>
                            </div>
                          </div>
                          <div className='w-100'>
                            <Row>
                              {(authCol.CultureId87 || {}).visible &&
                                <Col lg={12} xl={12}>
                                  <div className='form__form-group'>
                                    {((true && this.constructor.ShowSpinner(AdmScreenFilterState)) && <Skeleton height='20px' />) ||
                                      <label className='form__form-group-label'>{(columnLabel.CultureId87 || {}).ColumnHeader} <span className='text-danger'>*</span>{(columnLabel.CultureId87 || {}).ToolTip &&
                                        (<ControlledPopover id={(columnLabel.CultureId87 || {}).ColumnName} className='sticky-icon pt-0 lh-23' message={(columnLabel.CultureId87 || {}).ToolTip} />
                                        )}
                                      </label>
                                    }
                                    {((true && this.constructor.ShowSpinner(AdmScreenFilterState)) && <Skeleton height='36px' />) ||
                                      <div className='form__form-group-field'>
                                        <AutoCompleteField
                                          name='cCultureId87'
                                          onChange={this.FieldChange(setFieldValue, setFieldTouched, 'cCultureId87', false)}
                                          onBlur={this.FieldChange(setFieldValue, setFieldTouched, 'cCultureId87', true)}
                                          onInputChange={this.CultureId87InputChange()}
                                          value={values.cCultureId87}
                                          defaultSelected={CultureId87List.filter(obj => { return obj.key === CultureId87 })}
                                          options={CultureId87List}
                                          filterBy={this.AutoCompleteFilterBy}
                                          disabled={(authCol.CultureId87 || {}).readonly ? true : false} />
                                      </div>
                                    }
                                    {errors.cCultureId87 && touched.cCultureId87 && <span className='form__form-group-error'>{errors.cCultureId87}</span>}
                                  </div>
                                </Col>
                              }
                              {(authCol.FilterName87 || {}).visible &&
                                <Col lg={12} xl={12}>
                                  <div className='form__form-group'>
                                    {((true && this.constructor.ShowSpinner(AdmScreenFilterState)) && <Skeleton height='20px' />) ||
                                      <label className='form__form-group-label'>{(columnLabel.FilterName87 || {}).ColumnHeader} <span className='text-danger'>*</span>{(columnLabel.FilterName87 || {}).ToolTip &&
                                        (<ControlledPopover id={(columnLabel.FilterName87 || {}).ColumnName} className='sticky-icon pt-0 lh-23' message={(columnLabel.FilterName87 || {}).ToolTip} />
                                        )}
                                      </label>
                                    }
                                    {((true && this.constructor.ShowSpinner(AdmScreenFilterState)) && <Skeleton height='36px' />) ||
                                      <div className='form__form-group-field'>
                                        <Field
                                          type='text'
                                          name='cFilterName87'
                                          disabled={(authCol.FilterName87 || {}).readonly ? 'disabled' : ''} />
                                      </div>
                                    }
                                    {errors.cFilterName87 && touched.cFilterName87 && <span className='form__form-group-error'>{errors.cFilterName87}</span>}
                                  </div>
                                </Col>
                              }
                            </Row>
                          </div>
                          <div className='form__form-group mb-0'>
                            <Row className='btn-bottom-row'>
                              {useMobileView && <Col xs={3} sm={2} className='btn-bottom-column'>
                                <Button color='success' className='btn btn-outline-success account__btn' onClick={this.props.history.goBack} outline><i className='fa fa-long-arrow-left'></i></Button>
                              </Col>}
                              <Col
                                xs={useMobileView ? 9 : 12}
                                sm={useMobileView ? 10 : 12}>
                                <Row>
                                  {
                                    bottomButtonList
                                      .filter(v => v.expose)
                                      .map((v, i, a) => {
                                        if (this.ActionSuppressed(authRow, v.buttonType, (currMst || {}).ScreenFilterId86, currDtl.ScreenFilterHlpId87)) return null;
                                        const buttonCount = a.length;
                                        const colWidth = parseInt(12 / buttonCount, 10);
                                        const lastBtn = i === a.length - 1;
                                        const outlineProperty = lastBtn ? false : true;

                                        return (
                                          <Col key={v.tid} xs={colWidth} sm={colWidth} className='btn-bottom-column' >
                                            <Button color='success' type='button' outline={outlineProperty} className='account__btn' disabled={isSubmitting} onClick={this.ScreenButtonAction[v.buttonType]({ submitForm, naviBar, ScreenButton: v, mst: currMst, dtl: currDtl, useMobileView })}>{v.label}</Button>
                                          </Col>
                                        )
                                      })
                                  }
                                </Row>
                              </Col>
                            </Row>
                          </div>
                        </Form>
                      </div>
                    )}
                />
              </div>
            </div>
          </div>
        </div>
      </DocumentTitle>
    );
  };
};

const mapStateToProps = (state) => ({
  user: (state.auth || {}).user,
  error: state.error,
  AdmScreenFilter: state.AdmScreenFilter,
  global: state.global,
});

const mapDispatchToProps = (dispatch) => (
  bindActionCreators(Object.assign({},
    { showNotification: showNotification },
    { LoadPage: AdmScreenFilterReduxObj.LoadPage.bind(AdmScreenFilterReduxObj) },
    { AddDtl: AdmScreenFilterReduxObj.AddDtl.bind(AdmScreenFilterReduxObj) },
    { SavePage: AdmScreenFilterReduxObj.SavePage.bind(AdmScreenFilterReduxObj) },
    { SearchCultureId87: AdmScreenFilterReduxObj.SearchActions.SearchCultureId87.bind(AdmScreenFilterReduxObj) },
    { setTitle: setTitle },
    { setSpinner: setSpinner },
  ), dispatch)
)

export default connect(mapStateToProps, mapDispatchToProps)(DtlRecord);
