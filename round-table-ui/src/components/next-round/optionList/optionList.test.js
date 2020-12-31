import React from 'react';
import { render, screen } from '@testing-library/react';
import '@testing-library/jest-dom/extend-expect';
import OptionList from './optionList';

describe('<OptionList />', () => {
  test('it should mount', () => {
    render(<OptionList />);
    
    const optionList = screen.getByTestId('OptionList');

    expect(optionList).toBeInTheDocument();
  });
});